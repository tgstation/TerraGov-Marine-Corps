// Constants and Configuration

const DEFAULT_VOLUME_THRESHOLD = 0.01;
const VAD_DEBOUNCE_TIME = 200; // ms
const GAIN_SCALE_FACTOR = 50; // Slider 0-100 maps to gain 0-2

// Global State
let socket;
let localStream = null;
let peerConnections = new Map();
let audioElements = new Map();
let audioSenders = new Map();
let distances = new Map();
let mutedUsers = new Map();
let gainNode = null;
let vadAudioContext = null;
let vadAnalyser = null;
let vadSource = null;
let isVoiceActive = false;
let lastActiveTime = 0;
let isDeafened = false;
let isManuallyMuted = false;
let isMicTesting = false;
let previousDeafenedState = false;
let testAudioContext = null;
let testSource = null;
let delayNode = null;
let volumeThreshold = DEFAULT_VOLUME_THRESHOLD;
let sinkId = null; // Output device ID

// Extract sessionId from URL
const urlParams = new URLSearchParams(window.location.search);
const sessionId = urlParams.get('sessionId');
const socket_address = urlParams.get('socket_address');

const ICE_SERVERS = [
    { urls: 'stun:stun.l.google.com:19302' },    
    { urls: 'stun:stun1.l.google.com:19302' }, 
    { urls: 'stun:stun2.l.google.com:19302' },   
    { urls: `turn:${window.location.hostname}:3478`,
        credential: sessionId,
        username: sessionId,
    }
]

// Utility Functions
function toggleButton(buttonId, isActive) {
    const button = document.getElementById(buttonId);
    if (isActive) {
        button.classList.remove('toggled');
    } else {
        button.classList.add('toggled');
    }
}

function toggleRoomStatus(isConnected) {
    const roomStatus = document.getElementById('room_status');
    if (isConnected) {
        roomStatus.src = 'fastclown.gif';
        roomStatus.classList = 'active';
    } else {
        roomStatus.src = 'stopclown.png';
        roomStatus.classList = '';
    }
}

function updateStatus(message) {
    document.getElementById('status').innerText = message;
}

// Audio Device Management
async function populateDevices() {
    const devices = await navigator.mediaDevices.enumerateDevices();
    const audioInputs = devices.filter(device => device.kind === 'audioinput');
    const audioOutputs = devices.filter(device => device.kind === 'audiooutput');

    const inputSelect = document.getElementById('audioInput');
    inputSelect.innerHTML = audioInputs.map(device =>
        `<option value="${device.deviceId}" ${device.deviceId === 'default' ? 'selected' : ''}>${device.label || 'Default Input'}</option>`
    ).join('');

    const outputSelect = document.getElementById('audioOutput');
    outputSelect.innerHTML = audioOutputs.map(device =>
        `<option value="${device.deviceId}" ${device.deviceId === 'default' ? 'selected' : ''}>${device.label || 'Default Output'}</option>`
    ).join('');
}

async function handleInputChange(event) {
    const deviceId = event.target.value;
    if (localStream) {
        localStream.getTracks().forEach(track => track.stop());
    }

    localStream = await navigator.mediaDevices.getUserMedia({
        audio: { deviceId: { exact: deviceId } }
    });

    setupGainNode(localStream);
    setupVoiceActivityDetection();
    updateAudioSenders();

    if (isMicTesting) {
        stopMicTestPlayback();
        startMicTestPlayback();
    }
}

async function handleOutputChange(event) {
    sinkId = event.target.value;
    audioElements.forEach(audio => {
        audio.setSinkId(sinkId);
    });
}

// Microphone Access
async function getMic() {
    try {
        localStream = await navigator.mediaDevices.getUserMedia({ audio: true });
        await populateDevices();
        setupGainNode(localStream);
        setupVoiceActivityDetection();
        socket.emit('mic_access_granted');
    } catch (err) {
        console.error('Failed to get microphone access:', err);
    }
}
// Gain and Volume Control
function setupGainNode(stream) {
    const audioTrack = stream.getAudioTracks()[0];
    if (!audioTrack) {
        console.error('No audio track found in stream');
        return;
    }

    const ctx = new AudioContext();
    const src = ctx.createMediaStreamSource(new MediaStream([audioTrack]));
    const dst = ctx.createMediaStreamDestination();
    gainNode = ctx.createGain();

    src.connect(gainNode);
    gainNode.connect(dst);

    stream.removeTrack(audioTrack);
    stream.addTrack(dst.stream.getAudioTracks()[0]);

    updateGainFromSlider();
}

function updateGainFromSlider() {
    if (!gainNode) {
        console.warn('Gain node not initialized');
        return;
    }
    const sliderValue = parseFloat(document.getElementById('input_slider').value);
    const gainValue = sliderValue / GAIN_SCALE_FACTOR;
    gainNode.gain.value = gainValue;
}

function updateSensitivity() {
    const sliderValue = parseFloat(document.getElementById('sensitivity_slider').value);
    if (!isNaN(sliderValue)) {
        volumeThreshold = sliderValue;
    }
}

function updateVolumes() {
    const masterVolume = document.getElementById('volume_slider').value ;
    audioElements.forEach((audio, userCode) => {
        const isMuted = mutedUsers.get(userCode);
        if(!isMuted){
            const dist = distances.get(userCode) || 0;
            const linearBase = Math.max(0, 1 - dist / 10);
            // const baseVolume = Math.pow(linearBase, 2);
            const vol = linearBase * masterVolume
            audio.volume = vol
        }
        else {
            audio.volume = 0;
        }
    });
}

// Voice Activity Detection (VAD)
function setupVoiceActivityDetection() {
    if (vadAudioContext) {
        vadAudioContext.close();
    }

    vadAudioContext = new (window.AudioContext || window.webkitAudioContext)();
    vadSource = vadAudioContext.createMediaStreamSource(localStream);
    vadAnalyser = vadAudioContext.createAnalyser();
    vadAnalyser.fftSize = 2048;
    const bufferLength = vadAnalyser.frequencyBinCount;
    const dataArray = new Float32Array(bufferLength);

    vadSource.connect(vadAnalyser);

    function getRMS() {
        vadAnalyser.getFloatTimeDomainData(dataArray);
        let sum = 0;
        for (let i = 0; i < bufferLength; i++) {
            sum += dataArray[i] * dataArray[i];
        }
        return Math.sqrt(sum / bufferLength);
    }

    function monitorAudio() {
        const rms = getRMS();
        const now = Date.now();

        const indicator = document.getElementById('mic_test_visual_indicator');
        if (indicator) {
            const level = Math.min(1, rms / 0.5) * 100;
            const detected = rms > volumeThreshold;
            indicator.style.backgroundColor = detected ? 'green' : 'grey';
            indicator.style.width = `${level}%`;
        }

        if (!isManuallyMuted) {
            if (rms > volumeThreshold) {
                lastActiveTime = now;
                if (!isVoiceActive) {
                    isVoiceActive = true;
                    handleVoiceActivityChange(true);
                }
            } else if (isVoiceActive && now - lastActiveTime > VAD_DEBOUNCE_TIME) {
                isVoiceActive = false;
                handleVoiceActivityChange(false);
            }
        } else {
            if (isVoiceActive) {
                isVoiceActive = false;
                handleVoiceActivityChange(false);
            }
        }

        requestAnimationFrame(monitorAudio);
    }

    monitorAudio();
}

function handleVoiceActivityChange(active) {
    const voiceStatus = document.getElementById('voice_activity_status');
    voiceStatus.classList = active ? 'active' : '';
    socket.emit('voice_activity', { active });
    updateAudioSenders();
}

// Mute/Deafen Controls
function updateAudioSenders() {
    if (!localStream) return;
    const shouldSend = !isManuallyMuted && !isDeafened && isVoiceActive;
    const track = shouldSend ? localStream.getAudioTracks()[0] : null;
    audioSenders.forEach(sender => {
        sender.replaceTrack(track);
    });
}

function toggleMute(forceMute = false) {
    if (!localStream) return;
    if (isDeafened && !forceMute) {
        toggleDeafen();
        return;
    }
    isManuallyMuted = forceMute ? true : !isManuallyMuted;
    if (isManuallyMuted && isVoiceActive) {
        isVoiceActive = false;
        handleVoiceActivityChange(false);
    }
    updateAudioSenders();
    toggleButton('mute_toggle', !isManuallyMuted);
}

function toggleDeafen(forceDeafen = false) {
    if (!localStream) return;
    isDeafened = forceDeafen ? true : !isDeafened;
    isManuallyMuted = isDeafened;
    audioElements.forEach(audio => {
        audio.muted = isDeafened;
    });
    if (isDeafened && isVoiceActive) {
        isVoiceActive = false;
        handleVoiceActivityChange(false);
    }
    updateAudioSenders();
    toggleButton('mute_toggle', !isManuallyMuted);
    toggleButton('deafen_toggle', !isDeafened);
}

// Mic Test Functions
function startMicTestPlayback() {
    testAudioContext = new AudioContext();
    testSource = testAudioContext.createMediaStreamSource(localStream);
    delayNode = new DelayNode(testAudioContext, {delayTime:2})
    testSource.connect(delayNode);
    delayNode.connect(testAudioContext.destination);
}

function stopMicTestPlayback() {
    if (testSource) testSource.disconnect();
    if (delayNode) delayNode.disconnect();
    if (testAudioContext) testAudioContext.close();
    testAudioContext = null;
    testSource = null;
    delayNode = null;
}

function toggleMicTest() {
    if (!localStream) return;
    isMicTesting = !isMicTesting;
    const button = document.querySelector('.mic_test_container button');
    const buttonsContainer = document.getElementById('buttons');

    if (isMicTesting) {
        previousDeafenedState = isDeafened;
        buttonsContainer.classList.add('hide');
        toggleDeafen(true);
        startMicTestPlayback();
        button.textContent = 'stop test';
        button.classList.add('toggled');
    } else {
        stopMicTestPlayback();
        if (!previousDeafenedState) toggleDeafen();
        button.textContent = 'test mic';
        button.classList.remove('toggled');
        buttonsContainer.classList.remove('hide');
    }
}

// Peer Connection Management
function createPeerConnection(userCode, sendOffer) {
    const pc = new RTCPeerConnection({ iceServers: ICE_SERVERS });
    peerConnections.set(userCode, pc);

    const audio = document.createElement('audio');
    audio.autoplay = true;
    if (sinkId) audio.setSinkId(sinkId);
    audio.muted = isDeafened;
    audio.volume = document.getElementById('volume_slider').value;
    document.body.appendChild(audio);
    audioElements.set(userCode, audio);

    if (localStream) {
        const track = localStream.getAudioTracks()[0];
        const sender = pc.addTrack(track, localStream);
        audioSenders.set(userCode, sender);
        updateAudioSenders(); // Apply current state
    }

    let iceCandidates = [];

    pc.onicecandidate = (event) => {
        if (event.candidate) {
            iceCandidates.push(event.candidate);
            socket.emit('ice-candidate', { to: userCode, candidate: event.candidate });
        }
    };
    pc.oniceconnectionstatechange = () => {
        const state = pc.iceConnectionState;
        if (state === 'failed') {
            socket.emit('ice_failed')
            updateStatus('a peer connection failed, view console error for more info')
        }
    };
    pc.ontrack = (event) => {
        audio.srcObject = event.streams[0];
    };

    if (sendOffer) {
        pc.createOffer()
            .then(offer => pc.setLocalDescription(offer))
            .then(() => socket.emit('offer', { to: userCode, offer: pc.localDescription }))
            .catch(err => {
                console.error('Failed to create offer:', err);
                // updateStatus(`Failed to create WebRTC offer for ${userCode}: ${err.message}. Check microphone permissions, browser compatibility, or network stability.`);
            });
    }

    return pc;
}

addEventListener("icecandidateerror", (event) => {
    updateStatus('peer connection failed, view console for details')
    socket.emit('ice_failed', {event})
 })

function removePeer(userCode) {
    const pc = peerConnections.get(userCode);
    if (pc) {
        pc.close();
        peerConnections.delete(userCode);
    }
    const audio = audioElements.get(userCode);
    if (audio) {
        audio.remove();
        audioElements.delete(userCode);
    }
    audioSenders.delete(userCode);
    distances.delete(userCode);
}

// Socket Event Handlers
function setupSocketHandlers() {
    socket.on('update', (update) => {
        if (update.type === 'status') {
            updateStatus(update.data);
        }
    });

    socket.on('loc', (data) => {
        if (data.none === 1) {
            Array.from(peerConnections.keys()).forEach(removePeer);
            toggleRoomStatus(false);
        } else {
            const peers = data['peers']
            const myUserCode = data['own']
            const newUserCodes = new Set(Object.keys(peers));
            const currentUserCodes = new Set(peerConnections.keys());

            const added = [...newUserCodes].filter(code => !currentUserCodes.has(code));
            const removed = [...currentUserCodes].filter(code => !newUserCodes.has(code));

            removed.forEach(removePeer);

            added.forEach(code => {
                const sendOffer = myUserCode < code;
                createPeerConnection(code, sendOffer);
            });

            distances = new Map(Object.entries(peers));
            updateVolumes();
            toggleRoomStatus(peerConnections.size > 0);
        }
    });

    socket.on('offer', (data) => {
        const { from, offer } = data;
        const pc = peerConnections.get(from) || createPeerConnection(from, false);
        pc.setRemoteDescription(new RTCSessionDescription(offer))
            .then(() => pc.createAnswer())
            .then(answer => pc.setLocalDescription(answer))
            .then(() => socket.emit('answer', { to: from, answer: pc.localDescription }))
            .catch(err => console.error('Error handling offer:', err));
    });

    socket.on('answer', (data) => {
        const { from, answer } = data;
        const pc = peerConnections.get(from);
        if (pc) {
            pc.setRemoteDescription(new RTCSessionDescription(answer))
                .catch(err => console.error('Error setting remote description:', err));
        }
    });

    socket.on('ice-candidate', (data) => {
        const { from, candidate } = data;
        const pc = peerConnections.get(from);
        if (pc) {
            pc.addIceCandidate(new RTCIceCandidate(candidate))
                .catch(err => console.error('Error adding ICE candidate:', err));
        }
    });

    socket.on('server-shutdown', () => {
        cleanupConnections();
        updateStatus('Server shutting down. Connection closed.');
        toggleRoomStatus(false);
    });

    socket.on('disconnect', (reason) => {
        cleanupConnections();
        toggleRoomStatus(false);
    });

    socket.on('mute_mic', () => {
        toggleMute(true);
    });

    socket.on('deafen', () => {
        toggleDeafen(true);
    });

    // socket.emit('mute_usercode', {userCode: userCodeMuting, mute: muting})
    socket.on('mute_usercode', (data) => {
        const userCode = data['userCode']
        if(!userCode) return;
        const mute = data['mute']
        mutedUsers.set(userCode, mute)
        updateVolumes()
    })
}

function cleanupConnections() {
    peerConnections.forEach(pc => pc.close());
    peerConnections.clear();
    audioElements.forEach(audio => audio.remove());
    audioElements.clear();
    audioSenders.clear();
    distances.clear();
    if (localStream) {
        localStream.getTracks().forEach(track => track.stop());
    }
}

// UI Event Listeners
function setupUIListeners() {
    // Tooltip handling
    const triggers = document.querySelectorAll('.tooltip');
    const tooltip = document.getElementById('tooltip_box');
    triggers.forEach(trigger => {
        trigger.addEventListener('mouseenter', () => {
            tooltip.innerHTML = trigger.dataset.tip;
        });
    });

    // Buttons
    document.getElementById('mic').addEventListener('click', getMic);
    document.getElementById('mute_toggle').addEventListener('click', () => toggleMute());
    document.getElementById('deafen_toggle').addEventListener('click', () => toggleDeafen());
    document.getElementById('settings_button').addEventListener('click', toggleSettings);
    document.querySelector('.mic_test_container button').addEventListener('click', toggleMicTest);

    // Device changes
    navigator.mediaDevices.addEventListener('devicechange', populateDevices);
    document.getElementById('audioInput').addEventListener('change', handleInputChange);
    document.getElementById('audioOutput').addEventListener('change', handleOutputChange);

    // Sliders
    document.getElementById('input_slider').addEventListener('input', updateGainFromSlider);
    document.getElementById('sensitivity_slider').addEventListener('input', updateSensitivity);
    document.getElementById('volume_slider').addEventListener('input', updateVolumes);


    // Cleanup on unload
    window.addEventListener('unload', () => {
        if (vadAudioContext) vadAudioContext.close();
        if (localStream) {
            localStream.getTracks().forEach(track => track.stop());
        }
        cleanupConnections();
    });
}

function toggleSettings() {
    const settingsMenu = document.getElementById('settings');
    const isOpen = settingsMenu.classList.toggle('open');
    toggleButton('settings_button', !isOpen);
}

// Initialization
async function init() {
    socket = io(socket_address, { rejectUnauthorized: false });
    socket.emit('join', { sessionId: sessionId });
    setupSocketHandlers();
    setupUIListeners();
    await getMic();
}

init();
