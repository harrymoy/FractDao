import { createStyles, FormControl, makeStyles, Theme } from "@material-ui/core";
import { useState } from "react";
import GetVaultData from "../helpers/GetVaultData";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
      maxWidth: '80%',
      margin: '0 auto',
      width: '-webkit-fill-available'
    },
    lastElement: {
      marginBottom: 50,
    },
    input: {
      width: '100%',
      border: '1px solid #ccc',
      borderRadius: 4,
      boxSizing: 'border-box',
      padding: '12px 20px'
    },
    required: {
      color: 'red'
    },
    submit: {
      width: '30%',
      backgroundColor: '#4CAF50',
      color: 'white',
      padding: '14px 20px',
      margin: '8px 0',
      border: 'none',
      borderRadius: '4px',
      cursor: 'pointer',
      marginTop: '2rem'
    }  
  })
);

const MintToken = () => {
    const classes = useStyles();

    const [tokenAddress, setTokenAddress] = useState<string>("");
    const [tokenName, setTokenName] = useState<string>("");
    const [tokenSymbol, setTokenSymbol] = useState<string>("");
    const [nftAddress, setNftAddress] = useState<string>("");
    const [vaultId, setVaultId] = useState<number>(0);
    const [supply, setSupply] = useState<number>(0);

    const handleBlankValue = (val:string) => {
        return val.trim() === '' ? 0 : parseInt(val);
      }

    const mintToken = async () => {
        if(tokenName == "") {return false;}
        if(tokenSymbol == "") {return false;}
        if(nftAddress == "") {return false;}
        if(vaultId == 0) {return false;}
        if(supply == 0) {return false;}
        const address = GetVaultData.mintNft(tokenName, tokenSymbol, tokenAddress, vaultId, supply);
        return address;
    }

    return(
        <div>
            <div>
                <FormControl required={true} className={classes.root}>
                    <input
                        name="tokenName"
                        id="tokenName"
                        type="text"
                        value={tokenName}
                        onChange={(ev: React.ChangeEvent<HTMLInputElement>): void =>
                            setTokenName(ev.target.value)
                          }
                        className={classes.input}
                    />
                </FormControl>
                <FormControl required={true} className={classes.root}>
                    <input
                        name="tokenSymbol"
                        id="tokenSymbol"
                        type="text"
                        value={tokenSymbol}
                        onChange={(ev: React.ChangeEvent<HTMLInputElement>): void =>
                            setTokenSymbol(ev.target.value)
                          }
                        className={classes.input}
                    />
                </FormControl>
                <FormControl required={true} className={classes.root}>
                    <input
                        name="nftAddress"
                        id="nftAddress"
                        type="text"
                        value={nftAddress}
                        onChange={(ev: React.ChangeEvent<HTMLInputElement>): void =>
                            setNftAddress(ev.target.value)
                          }
                        className={classes.input}
                    />
                </FormControl>
                <FormControl required={true} className={classes.root}>
                    <input
                        name="vaultId"
                        id="vaultId"
                        type="number"
                        value={vaultId}
                        onChange={(ev: React.ChangeEvent<HTMLInputElement>): void =>
                            setVaultId(handleBlankValue(ev.target.value))
                          }
                        className={classes.input}
                    />
                </FormControl>
                <FormControl required={true} className={classes.root}>
                    <input
                        name="supply"
                        id="supplu"
                        type="number"
                        value={supply}
                        onChange={(ev: React.ChangeEvent<HTMLInputElement>): void =>
                            setSupply(handleBlankValue(ev.target.value))
                          }
                        className={classes.input}
                    />
                </FormControl>
                <span></span>
                <input className={classes.submit} onClick={mintToken} type="submit" value="Submit"/>
            </div>
        </div>
    )
}

export default MintToken;