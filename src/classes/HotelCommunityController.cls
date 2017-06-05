public abstract with sharing class HotelCommunityController{
    public Contact contact {get; set;}
    public HotelCommunityController(){
        contact = HotelCommunityService.getContact(HotelCommunityService.getUserId());
  
    }
}