cd ~
git clone https://github.com/SpaceManiac/SpacemanDMM.git
cd SpacemanDMM
cargo build
cd ~/tgstation/TerraGov-Marine-Corps
if [ ~/SpacemanDMM/target/release/dreamchecker ]; then
  echo "dreamchecker errors found"
  exit 1
fi
