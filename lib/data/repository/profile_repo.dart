import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_restaurant/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_restaurant/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_restaurant/data/model/response/base/api_response.dart';
import 'package:flutter_restaurant/data/model/response/userinfo_model.dart';
import 'package:flutter_restaurant/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfileRepo{
  final DioClient dioClient;
  final SharedPreferences sharedPreferences;
  ProfileRepo({@required this.dioClient, @required this.sharedPreferences});

  Future<ApiResponse> getAddressTypeList() async {
    try {
      List<String> addressTypeList = [
        'Select Address type',
        'Home',
        'Office',
        'Other',
      ];
      Response response = Response(requestOptions: RequestOptions(path: ''), data: addressTypeList, statusCode: 200);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getUserInfo() async {
    try {
      final response = await dioClient.get(AppConstants.CUSTOMER_INFO_URI);
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  // Future<http.StreamedResponse> updateProfile(UserInfoModel userInfoModel, String password, File file, String token) async {
  //   http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse('${AppConstants.BASE_URL}${AppConstants.UPDATE_PROFILE_URI}'));
  //   request.headers.addAll(<String,String>{'Authorization': 'Bearer $token'});
  //   if(file != null) {
  //     request.files.add(http.MultipartFile('image', file.readAsBytes().asStream(), file.lengthSync(), filename: file.path.split('/').last));
  //   }
  //   Map<String, String> _fields = Map();
  //   if(password.isEmpty) {
  //     _fields.addAll(<String, String>{
  //       '_method': 'put', 'f_name': userInfoModel.fName, 'l_name': userInfoModel.lName, 'phone': userInfoModel.phone
  //     });
  //   }else {
  //     _fields.addAll(<String, String>{
  //       '_method': 'put', 'f_name': userInfoModel.fName, 'l_name': userInfoModel.lName, 'phone': userInfoModel.phone, 'password': password
  //     });
  //   }
  //   request.fields.addAll(_fields);
  //   http.StreamedResponse response = await request.send();
  //   return response;
  // }

  Future<ApiResponse> updateProfile(UserInfoModel userInfoModel) async {
    try {
      final response = await dioClient.post(
        AppConstants.UPDATE_PROFILE_URI,
        data: userInfoModel.toJson(),
      );

      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}