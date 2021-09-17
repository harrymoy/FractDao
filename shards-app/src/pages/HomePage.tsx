import { createStyles, Theme, makeStyles } from "@material-ui/core";
import { useEffect } from "react";


const useStyles = makeStyles((theme: Theme) =>
  createStyles({

  })
);

const HomePage = () => {
    const classes = useStyles();

    useEffect(() => {
        document.title = "Shards";
    })

    return(
        <div>Fractionalized NFTs</div>
    )
}

export default HomePage;