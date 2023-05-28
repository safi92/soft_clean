class AddressModel {
  int id;
  String addressType;
  String contactPersonNumber;

  String zipCode;
  String city;

  String address;
  String latitude;
  String longitude;
  String createdAt;
  String updatedAt;
  int userId;
  String method;
  String contactPersonName;

  AddressModel(
      {this.id,
      this.addressType,
      this.contactPersonNumber,
      this.zipCode,
      this.city,
      this.address,
      this.latitude,
      this.longitude,
      this.createdAt,
      this.updatedAt,
      this.userId,
      this.method,
      this.contactPersonName});

  AddressModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
     print("yes ok");
     print(id);
    addressType = json['address_type'];
    contactPersonNumber = json['contact_person_number'];
    zipCode = json['zip_code'];
    city = json['city'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userId = json['user_id'];
    method = json['_method'];
    contactPersonName = json['contact_person_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['address_type'] = this.addressType;
    data['contact_person_number'] = this.contactPersonNumber;

    data['zip_code'] = this.zipCode;
    data['city'] = this.city;
    
    data['address'] = this.address;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_id'] = this.userId;
    data['_method'] = this.method;
    data['contact_person_name'] = this.contactPersonName;
    print("yes");
    print(data);
    return data;
  }
}
