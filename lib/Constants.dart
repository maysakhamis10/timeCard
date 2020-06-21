class Constants {
     static  String baseUrl = "https://mobileapp.itgsolutions.com/EmployeePortal/";
     static  String CheckIn = "CheckIn";
    static String getLoginUrl(String userName, String pass, String macAddress) {
      String loginurl = baseUrl;
      loginurl += "LogIn?" + "Username=" + userName + "&Password=" + pass + "&MacAddress=" + macAddress;
      return loginurl;
   }
      static String getCheckUrl(String type) {
       String checkUrl = baseUrl;

       if (type==CheckIn) {
         checkUrl += "CheckIn";
       } else {
         checkUrl += "CheckOut";

       }
       //  checkUrl += "employeeId=" + EmployeeId + "&apiKey=" + apiKey + "&logginMachine=" + logginMachine + "&location=" + location + "&client=" + client + "&addressInfo=" + addressInfo + "&checkInTime=" + checkInTime;

       return checkUrl;
     }

}