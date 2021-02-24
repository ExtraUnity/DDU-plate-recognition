class LicencePlate{
  String plateURL;
  String carURL;
  
  PImage platePicture;
  PImage carPicture;
  
  String realPlate;
  
  String foundPlate;
  
  LicencePlate(String _plateURL, String _carURL, String _realPlate){
    this.plateURL = _plateURL;
    this.carURL = _carURL;
    this.realPlate = _realPlate;
    
    this.platePicture = loadImage(_plateURL);
    this.carPicture = loadImage(_carURL);
  }
  
  LicencePlate(XML instructions){
    // TODO: implement this
  
  }
}
