import { createStyles, Theme, makeStyles } from "@material-ui/core";
import { useEffect } from "react";


const useStyles = makeStyles((theme: Theme) =>
  createStyles({

  })
);

const Governance = () => {
    const classes = useStyles();

    useEffect(() => {
        document.title = "Governance";
    })

    return(<div>
            <div>Fractionalized NFTs</div>
        </div>
    )
}

export default Governance;