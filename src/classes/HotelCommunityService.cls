public class HotelCommunityService{
/*
Return the current user.
*/
    public static id getUserId(){
        return UserInfo.getUserId();
    }
/*Return contact and all fields applicable to community associated with community user*/
    public static Contact getContact(Id userId){
        Contact c = null;
        User u = [Select id,contactId from User where Id = :userid];
        if(u != null && u.contactId != null){
        c = [select Id,Hotel__c,Hotel_Image__c from Contact where Id = :u.ContactId];
        }
    return c;
    }

/*returns specific info bat single hotel*/
    public static Hotel__c getHotel(Id hotelId){
        Hotel__c hotel = null;
        if(hotelId != null){
            hotel = [select id,Name,Background_Image__c,Home_Page_Image__c,Home_Page_Text__c from Hotel__c where id = :hotelId];
        }
        return hotel;
    }

/*returns List of news items bat single hotel ordered newest to oldest*/
public static list<HotelNewsItem> getHotelNews(Id hotelId){
    List<HotelNewsItem> newsList = new List<HotelNewsItem>{};
    if(hotelId != null){
        for(Hotel_News__c hn : [select Id, Name , Content__c, Title__c, CreatedDate from Hotel_News__c where Hotel__c = :hotelId order by CreatedDate DESC]){
        HotelNewsItem hni = new HotelNewsItem(hn);
        newsList.add(hni);
        }
    }
    return newsList;
}

/*returns list of rooms associated with given hotel id*/
public static List<Room__c> getRooms(Id hotelId){
    List<Room__c> hotelRooms = new List<Room__c>{};
    if(hotelId != null){
        for(Room__c room : [select id, Description__c, Price__c, Room_Image__c from Room__c where Hotel__c = :hotelId order by Price__c]){
            hotelRooms.add(room);
        }
    }
    return hotelRooms;
}

/*wrapper of hotel news item and provide cleaner date formatting*/
public class HotelNewsItem{
    private Hotel_News__c news;
    public HotelNewsItem(Hotel_News__c Item) { this.news = item; }

    public String id { get { return news.Id; } }
    public String name { get { return news.Name; } }
    public String title { get { return news.Title__c; } }
    public String content { get { return news.Content__c; } }
    public String createDate{
        get {
            return news.CreatedDate.format('MM/dd/yyyy hh:mm:a');
        }
    }
    }
    }