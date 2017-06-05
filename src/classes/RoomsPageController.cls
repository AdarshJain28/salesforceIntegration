public with sharing class RoomsPageController extends HotelCommunityController{
    public List<Room__c> hotelRooms {get; set;}
    
    public RoomsPageController(){
        super();
        String hotelId = ApexPages.currentPage().getParameters().get('hotelId');
        hotelRooms = HotelCommunityService.getRooms(hotelId);
    }
}