public with sharing class HotelPageController extends HotelCommunityController{
    public Hotel__c hotel {get; set;}
    public List< HotelCommunityService.HotelNewsItem> hotelNews {get; set;}
    

    public HotelPageController(){
        Id hotelId = ApexPages.currentPage().getParameters().get('id');
        hotel = HotelCommunityService.getHotel(hotelId);
       // hotelNews = HotelCommunityService.getHotelNews(contact.Hotel__c);
    }
}