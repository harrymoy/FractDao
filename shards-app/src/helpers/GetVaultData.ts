import { ethers } from "ethers";
import FractDao from '../abis/FractDao.sol/FractDao.json';
import VaultList from "../models/VaultList";
import Vault from "../models/Vaults";

declare let window: any
const contractAddress = "0x96BA00E8A7419D6Ca87Bc512FC259AF2da878f73";

const connectContract = async() => {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();
    var fractDaoContract = new ethers.Contract(
        contractAddress,
        FractDao,
        signer
    );
    return fractDaoContract;
}

const mintNft = async(tokenName: string, tokenSymbol: string, tokenAddress: string, id: number, supply: number) => {
    const fractDaoContract = await connectContract();
    const mintToken =  await fractDaoContract.mint(tokenName, tokenSymbol, tokenAddress, id, supply);
    console.log("Minted", mintToken);
    return mintToken;
}

const getVaultData = async(tokenAddress: string) => {
    const fractDaoContract = await connectContract();
    const vaultResult = await fractDaoContract.getVaultFromRecord(tokenAddress);
    console.log(vaultResult);
    var vault = new Vault(vaultResult!.creator, vaultResult!.name, vaultResult!.supply);
    return vault
}

const getAllVaults = async(): Promise<VaultList | undefined> => {
    const fractDaoContract = await connectContract();
    const vaultsResult = await fractDaoContract.getAllVaults();
    console.log("Vaults result", vaultsResult);
    const vaultList = new VaultList(vaultsResult);
    return vaultList;
}

export default {getVaultData, getAllVaults, mintNft};