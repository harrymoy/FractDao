class Vault {
    imageLink: string;
    name: string;
    price: number;

    constructor(_imageLink: string, _name: string, _price: number) {
        this.imageLink = _imageLink;
        this.name = _name;
        this.price = _price;
    }
}

export default Vault;