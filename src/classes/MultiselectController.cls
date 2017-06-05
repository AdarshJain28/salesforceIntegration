public class MultiselectController {
    public SelectOption[] leftOption { get; set; }
    public SelectOption[] rightOption { get; set; }
    
    
    private void setOptions(SelectOption[] options, String value) {
        options.clear();
        String[] parts = value.split('&');
        for (Integer i=0; i<parts.size()/2; i++) {
            options.add(new SelectOption(EncodingUtil.urlDecode(parts[i*2], 'UTF-8'), 
              EncodingUtil.urlDecode(parts[(i*2)+1], 'UTF-8')));
        }
    }
    
   
    public String leftOptionsHidden { get; set {
           leftOptionsHidden = value;
           setOptions(leftOption, value);
        }
    }
    
    
    public String rightOptionsHidden { get; set {
           rightOptionsHidden = value;
           setOptions(rightOption, value);
        }
    }
}