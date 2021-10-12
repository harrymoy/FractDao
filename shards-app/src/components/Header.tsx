import { AppBar, createStyles, makeStyles, Theme, Toolbar } from "@material-ui/core";
import { NavLink } from "react-router-dom";

const useStyles = makeStyles((theme: Theme) =>
    createStyles({
        toolbar: {
            backgroundColor: 'black',
        },
        navText: {
            color: 'white',
            marginLeft: '20px'
        },
        titleText: {
            color: 'whilte',
            fontSize: '30px'
        }
    })
)

const AppHeader = () => {
    const styles = useStyles();

    return(
        <div>
            <AppBar className={styles.toolbar}>
                <Toolbar>
                    <NavLink to="/"><div className={styles.titleText}>FractlDao</div></NavLink>
                    <NavLink to="/"><div className={styles.navText}>Dashboard</div></NavLink>
                    <NavLink to="/"><div className={styles.navText}>Browse</div></NavLink>
                    <NavLink to="/MyAccount"><div className={styles.navText}>My Account</div></NavLink>
                    <NavLink to="/Governance"><div className={styles.navText}>Governance</div></NavLink>
                    <NavLink to="/Mint"><div className={styles.navText}>Mint Token</div></NavLink>
                </Toolbar>
            </AppBar>
        </div>
    )
}

export default AppHeader;