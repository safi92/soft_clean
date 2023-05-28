import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/response_model.dart';
import 'package:flutter_restaurant/data/model/response/userinfo_model.dart';
import 'package:flutter_restaurant/data/repository/profile_repo.dart';
import 'package:flutter_restaurant/helper/api_checker.dart';
import 'package:flutter_restaurant/view/base/custom_snackbar.dart';
import 'package:http/http.dart' as http;

class ProfileProvider with ChangeNotifier {
  final ProfileRepo profileRepo;

  ProfileProvider({@required this.profileRepo});

  UserInfoModel _userInfoModel;

  UserInfoModel get userInfoModel => _userInfoModel;

  Future<ResponseModel> getUserInfo(BuildContext context) async {
    ResponseModel _responseModel;
    ApiResponse apiResponse = await profileRepo.getUserInfo();
    if (apiResponse.response != null && apiResponse.response.statusCode == 200) {
      _userInfoModel = UserInfoModel.fromJson(apiResponse.response.data);
      _responseModel = ResponseModel(true, 'successful');

     
     
     
    } else {
      String _errorMessage;
      if (apiResponse.error is String) {
        _errorMessage = apiResponse.error.toString();
      } else {
        _errorMessage = apiResponse.error.errors[0].message;
      }
      print(_errorMessage);
      _responseModel = ResponseModel(false, _errorMessage);
      ApiChecker.checkApi(context, apiResponse);
    }
    notifyListeners();
    return _responseModel;
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String password, File file, String token) async {
  Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel) async {
    _isLoading = true;
    notifyListeners();
    ResponseModel _responseModel;
    // http.StreamedResponse response = await profileRepo.updateProfile(updateUserModel, password, file, token);
    // http.StreamedResponse response =
    //     await profileRepo.updateProfile(updateUserModel, password, file, token);
    ApiResponse apiResponse = await profileRepo.updateProfile(updateUserModel);

    _isLoading = false;
     if (apiResponse.response.statusCode == 200) {
      // Map map = jsonDecode(await response.stream.bytesToString());
      // String message = map["message"];
      String message = "OKAY";
      _userInfoModel = updateUserModel;
      _responseModel = ResponseModel(true, message);
      print(message);
    } else {
      _responseModel = ResponseModel(false, apiResponse.response.data);
      // print('${apiResponse.response.statusCode} ${apiResponse.response.reasonPhrase}');
      print(apiResponse.response.statusCode);
    }
    notifyListeners();
    return _responseModel;
  }




}
