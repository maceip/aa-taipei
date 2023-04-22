import { HardhatRuntimeEnvironment } from 'hardhat/types'
import { DeployFunction } from 'hardhat-deploy/types'
import { ethers } from 'hardhat'

const deploySimpleAccountFactory: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const provider = ethers.provider
  const from = await provider.getSigner().getAddress()
  console.log("hee");
  const entrypoint = await hre.deployments.get('EntryPoint')
  
  const nft = await hre.ethers.getContractFactory("ERC721Token")
  const [, alice, bob] = await hre.ethers.getSigners()

  const BubblegumToken = await nft.deploy()


  const ret = await hre.deployments.deploy(
    'MechFactory', {
      from,
      args: [entrypoint.address],
      gasLimit: 6e6,
      log: true,
      deterministicDeployment: true
    })

    const meca = await ethers.getContractFactory('MechFactory');
    const proxy = meca.attach(ret.address);
    const generated = await proxy.callStatic.createAccount(BubblegumToken.address, 1, 999);
    console.log(generated);


}



export default deploySimpleAccountFactory
