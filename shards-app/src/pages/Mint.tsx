import { createStyles, makeStyles, Paper, Theme, Typography } from "@material-ui/core";
import MintToken from "../components/MintToken";

const useStyles = makeStyles((theme: Theme) =>
  createStyles({
    root: {
        maxWidth: "75%",
        margin: "0 auto"
    },
    form: {
        paddingTop: theme.spacing(6),
        paddingBottom: theme.spacing(2),
        textAlign: 'center'
      }
  })
);


const Mint = () => {
    const styles = useStyles();

    return(
        <div className={styles.root}>
        <Paper 
        className={styles.form} 
        elevation={1}
        square={false}
        >
          <Typography variant="h1" component="h3">
            Mint your Token
          </Typography>
          <MintToken />
        </Paper>
      </div>
    )
}

export default Mint;