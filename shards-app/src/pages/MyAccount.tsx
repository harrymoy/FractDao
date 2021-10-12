import { createStyles, Theme, makeStyles } from "@material-ui/core";
import { useEffect, useState } from "react";
import { getWalletData } from "../helpers/GetWalletData";


const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    body: {
        color: 'grey'
    }
  })
);

const MyAccount = () => {
    const classes = useStyles();
    const [userAddress, setUserAddress] = useState<string>("");

    const getWalletAddress = async() => {
        const walletData = await getWalletData();
        const address = walletData![0];
        setUserAddress(address);
    }

    useEffect(() => {
        document.title = "My Account";
        getWalletAddress();
    }, [userAddress])

    return(<div className={classes.body}>
            <div>My Account</div>
            <div>{userAddress}</div>
        </div>
    )
}

export default MyAccount;