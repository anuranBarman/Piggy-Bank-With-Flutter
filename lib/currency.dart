class Currency {
  String cc;
  String symbol;
  String name;

  Currency(this.cc,this.symbol,this.name);

  factory Currency.fromJson(Map<dynamic,dynamic> json){
    return Currency(json["cc"], json["symbol"], json["name"]);
  }
}