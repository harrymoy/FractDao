import React from "react";
import Vault from "../models/Vaults";

interface NftItemProps {
    vault: Vault;
}

const NftItem = (props: NftItemProps) => {
    return(
        <div>
            <img src={props.vault.imageLink} alt={props.vault.name}/>
            <div>
                <p>{props.vault.name}</p>
                <p>{props.vault.price}</p>
            </div>
        </div>
    )
}

export default NftItem;