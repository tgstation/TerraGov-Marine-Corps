import { AirlockElectronics } from './interfaces/AirlockElectronics';
import { Apc } from './interfaces/APC';
import { AtmosAlertConsole } from './interfaces/AtmosAlertConsole';
import { AtmosControlConsole } from './interfaces/AtmosControlConsole';
import { AtmosFilter } from './interfaces/AtmosFilter';
import { AtmosMixer } from './interfaces/AtmosMixer';
import { AtmosPump } from './interfaces/AtmosPump';
import { BorgPanel } from './interfaces/BorgPanel';
import { BrigTimer } from './interfaces/BrigTimer';
import { Canister } from './interfaces/Canister';
import { Cargo } from './interfaces/Cargo';
import { CAS } from './interfaces/CAS';
import { ChemDispenser } from './interfaces/ChemDispenser';
import { Crayon } from './interfaces/Crayon';
import { Crew } from './interfaces/Crew';
import { Cryo } from './interfaces/Cryo';
import { DisposalUnit } from './interfaces/DisposalUnit';
import { KitchenSink } from './interfaces/KitchenSink';
import { ThermoMachine } from './interfaces/ThermoMachine';
import { Wires } from './interfaces/Wires';
import { MarineSelector } from './interfaces/MarineSelector';
import { SelfDestruct } from './interfaces/SelfDestruct';
import { Sentry } from './interfaces/Sentry';
import { Vending } from './interfaces/Vending';
import { MarineDropship } from './interfaces/MarineDropship';
import { CentcomPodLauncher } from './interfaces/CentcomPodLauncher';
import { PortableVendor } from './interfaces/PortableVendor';
import { PortableGenerator } from './interfaces/PortableGenerator';
import { ShuttleManipulator } from './interfaces/ShuttleManipulator';
import { SmartVend } from './interfaces/SmartVend';
import { SMES } from './interfaces/SMES';


const ROUTES = {
  airlock_electronics: {
    component: () => AirlockElectronics,
    scrollable: false,
  },
  apc: {
    component: () => Apc,
    scrollable: false,
  },
  atmos_alert: {
    component: () => AtmosAlertConsole,
    scrollable: true,
  },
  atmos_control: {
    component: () => AtmosControlConsole,
    scrollable: true,
  },
  atmos_filter: {
    component: () => AtmosFilter,
    scrollable: false,
  },
  atmos_mixer: {
    component: () => AtmosMixer,
    scrollable: false,
  },
  atmos_pump: {
    component: () => AtmosPump,
    scrollable: false,
  },
  borgopanel: {
    component: () => BorgPanel,
    scrollable: true,
  },
  brig_timer: {
    component: () => BrigTimer,
    scrollable: false,
  },
  canister: {
    component: () => Canister,
    scrollable: false,
  },
  cargo: {
    component: () => Cargo,
    scrollable: true,
  },
  cas: {
    component: () => CAS,
    scrollable: true,
  },
  crew: {
    component: () => Crew,
    scrollable: true,
  },
  chem_dispenser: {
    component: () => ChemDispenser,
    scrollable: true,
  },
  crayon: {
    component: () => Crayon,
    scrollable: true,
  },
  cryo: {
    component: () => Cryo,
    scrollable: true,
  },
  disposal_unit: {
    component: () => DisposalUnit,
    scrollable: false,
  },
  marineselector: {
    component: () => MarineSelector,
    scrollable: true,
  },
  marinedropship: {
    component: () => MarineDropship,
    scrollable: true,
  },
  centcom_podlauncher: {
    component: () => CentcomPodLauncher,
    scrollable: false,
  },
  portable_generator: {
    component: () => PortableGenerator,
    scrollable: false,
  },
  portablevendor: {
    component: () => PortableVendor,
    scrollable: true,
  },
  selfdestruct: {
    component: () => SelfDestruct,
    scrollable: false,
  },
  sentry: {
    component: () => Sentry,
    scrollable: false,
  },
  shuttle_manipulator: {
    component: () => ShuttleManipulator,
    scrollable: true,
  },
  smartvend: {
    component: () => SmartVend,
    scrollable: true,
  },
  smes: {
    component: () => SMES,
    scrollable: true,
  },
  vending: {
    component: () => Vending,
    scrollable: true,
  },
  thermomachine: {
    component: () => ThermoMachine,
    scrollable: false,
  },
  wires: {
    component: () => Wires,
    scrollable: false,
  },
};

export const getRoute = state => {
  // Show a kitchen sink
  if (state.showKitchenSink) {
    return {
      component: () => KitchenSink,
      scrollable: true,
    };
  }
  // Refer to the routing table
  return ROUTES[state.config && state.config.interface];
};
