import { createStyles, makeStyles, Theme } from "@material-ui/core";
import { useEffect } from "react";
import Vault from "../models/Vaults";
import NftItem from "./NFTItem";
import Sidebar from "./Sidebar";

interface BrowseProps {
    vault?: Vault;
}

const useStyles = makeStyles((theme: Theme) => 
    createStyles({
        main: {
            width: "500px",
            height: "500px"
        }
    })
);

const Browse = (props: BrowseProps) => {
    const styles = useStyles();

    useEffect(() => {
        document.title = props.vault?.name!;
    })

    return(
        <div className={styles.main}>
            <Sidebar/>
            {/* <NftItem imageLink={props.vault?.imageLink!} name={props.name!} price={props.price!}/> */}
        </div>
    )
}

export default Browse;