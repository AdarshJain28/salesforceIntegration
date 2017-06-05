public class calWrapper {
    public static void consumeObject(JSONParser parser) {
        Integer depth = 0;
        do {
            JSONToken curr = parser.getCurrentToken();
            if (curr == JSONToken.START_OBJECT || 
                curr == JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == JSONToken.END_OBJECT ||
                curr == JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    public class Reminders {
        public Boolean useDefault {get;set;} 

        public Reminders(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'useDefault') {
                            useDefault = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Reminders consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public String kind {get;set;} 
    public String etag {get;set;} 
    public String summary {get;set;} 
    public String updated {get;set;} 
    public String timeZone {get;set;} 
    public String accessRole {get;set;} 
    public List<DefaultReminders> defaultReminders {get;set;} 
    public String nextSyncToken {get;set;} 
    public List<Items> items {get;set;} 

    public calWrapper(JSONParser parser) {
        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != JSONToken.VALUE_NULL) {
                    if (text == 'kind') {
                        kind = parser.getText();
                    } else if (text == 'etag') {
                        etag = parser.getText();
                    } else if (text == 'summary') {
                        summary = parser.getText();
                    } else if (text == 'updated') {
                        updated = parser.getText();
                    } else if (text == 'timeZone') {
                        timeZone = parser.getText();
                    } else if (text == 'accessRole') {
                        accessRole = parser.getText();
                    } else if (text == 'defaultReminders') {
                        defaultReminders = new List<DefaultReminders>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            defaultReminders.add(new DefaultReminders(parser));
                        }
                    } else if (text == 'nextSyncToken') {
                        nextSyncToken = parser.getText();
                    } else if (text == 'items') {
                        items = new List<Items>();
                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                            items.add(new Items(parser));
                        }
                    } else {
                        System.debug(LoggingLevel.WARN, 'Root consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class Start {
        public String dateTime_x {get;set;}
        public String date_x {get;set;} 
        
        public Start(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'date_x') {
                            date_x = parser.getText();
                        } else if (text == 'dateTime_x') {
                            dateTime_x = parser.getText();
                        }
                        else {
                            System.debug(LoggingLevel.WARN, 'Start consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class DefaultReminders {
        public String method {get;set;} 
        public Integer minutes {get;set;} 

        public DefaultReminders(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'method') {
                            method = parser.getText();
                        } else if (text == 'minutes') {
                            minutes = parser.getIntegerValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'DefaultReminders consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Items {
        public String kind {get;set;} 
        public String etag {get;set;} 
        public String id {get;set;} 
        public String status {get;set;} 
        public String htmlLink {get;set;} 
        public String created {get;set;} 
        public String updated {get;set;} 
        public String summary {get;set;} 
        public Creator creator {get;set;} 
        public Creator organizer {get;set;} 
        public Start start {get;set;} 
        public Start end_Z {get;set;} // in json: end
        public String iCalUID {get;set;} 
        public Integer sequence {get;set;} 
        public Reminders reminders {get;set;} 
        public String transparency {get;set;} 

        public Items(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'kind') {
                            kind = parser.getText();
                        } else if (text == 'etag') {
                            etag = parser.getText();
                        } else if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'htmlLink') {
                            htmlLink = parser.getText();
                        } else if (text == 'created') {
                            created = parser.getText();
                        } else if (text == 'updated') {
                            updated = parser.getText();
                        } else if (text == 'summary') {
                            summary = parser.getText();
                        } else if (text == 'creator') {
                            creator = new Creator(parser);
                        } else if (text == 'organizer') {
                            organizer = new Creator(parser);
                        } else if (text == 'start') {
                            start = new Start(parser);
                        } else if (text == 'end') {
                            end_Z = new Start(parser);
                        } else if (text == 'iCalUID') {
                            iCalUID = parser.getText();
                        } else if (text == 'sequence') {
                            sequence = parser.getIntegerValue();
                        } else if (text == 'reminders') {
                            reminders = new Reminders(parser);
                        } else if (text == 'transparency') {
                            transparency = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Items consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Creator {
        public String email {get;set;} 
        public Boolean self {get;set;} 

        public Creator(JSONParser parser) {
            while (parser.nextToken() != JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != JSONToken.VALUE_NULL) {
                        if (text == 'email') {
                            email = parser.getText();
                        } else if (text == 'self') {
                            self = parser.getBooleanValue();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Creator consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
   
    
    
    public static calWrapper parse(String json) {
        return new calWrapper(System.JSON.createParser(json));
    }
}