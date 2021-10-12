import { createStyles, makeStyles, Theme } from "@material-ui/core";
import GetVaultData from "../helpers/GetVaultData";
import { useEffect, useState } from "react";
import Vault from "../models/Vaults";
import NftItem from "./NFTItem";
import vaults from "../helpers/vaults.json"

const useStyles = makeStyles((theme: Theme) => 
    createStyles({
        sidebar: {
            color: 'black',
            display: 'grid',
            columnWidth: '20px'
        }
    })
)
interface ListofVaults {
    imageLink: string;
    name: string;
    price: number;
}
const Sidebar = () => {
    const styles = useStyles();
    const [nftVaults, setNftVaults] = useState<ListofVaults[]>([]);

    useEffect(() =>{ 
        getVaultData();
    }, [nftVaults])

    const getVaultData = async() => {
        // const vaultList = await GetVaultData.getAllVaults();
        // console.log("Vault list is", vaultList);
        setNftVaults(vaults);
    }

    const renderItems = (vaults: Vault[]) => {
        if (vaults.length == 0) {
            var emptyVault = new Vault("", "", 0);
            return <NftItem vault={emptyVault}/>
        }
        return vaults.map(vault => {
            return <NftItem vault={vault}/>;
        })
    }

    return(
        <div className={styles.sidebar}>
            {renderItems(nftVaults!)}
        </div>
    )
}

export default Sidebar;