import Vault from "./Vaults";

class VaultList {
    list: Array<Vault>;
    constructor(_list: Array<Vault>) {
        this.list = _list;
    }
}

export default VaultList;