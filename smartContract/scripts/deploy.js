const hre = require("hardhat");

async function main() {
  const smartWalletContract = await hre.ethers.deployContract(
    "SmartWalletFactory",
    ["0x0576a174D229E3cFA37253523E645A78A0C91B57"]
  );

  await smartWalletContract.waitForDeployment();

  console.log(`Smart Wallet Factory deployed to ${smartWalletContract.target}`);

  const ETHHolder = "0x1b6e16403b06a51C42Ba339E356a64fE67348e92";

  const smartWallet = await ethers.getContractAt(
    "CustodialInterface",
    "0x28315c467b82b57f8F3Bad9338C7819b048Ae222"
  );

  const ETHHolderImpersonate = await ethers.getImpersonatedSigner(ETHHolder);

  const string = await smartWallet
    .connect(ETHHolderImpersonate)
    .deployWallet(1234);
  console.log(string);
  const string2 = await smartWallet
    .connect(ETHHolderImpersonate)
    .hasAnAccountAndReturn();

  console.log(string2);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
