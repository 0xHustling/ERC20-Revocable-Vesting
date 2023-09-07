const hre = require("hardhat");
const vestings = require("../scripts/vesting.json");

async function main() {
  for (let i = 0; i < vestings.length; i++) {
    console.log("Starting deploy...");
    const Vesting = await hre.ethers.getContractFactory("RevocableVesting");
    const vesting = await Vesting.deploy(
      vestings[i].address,
      process.env.VESTING_CONTROLLER,
      process.env.VESTED_TOKEN_ADDRESS,
      process.env.START_TIME,
      ethers.utils.parseEther(vestings[i].amount),
      process.env.NUMBER_OF_EPOCHS,
      process.env.EPOCH_DURATION
    );

    await vesting.deployed();
    console.log(`Vesting of ${vestings[i].name} deployed to: https://etherscan.io/address/${vesting.address}`);
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
