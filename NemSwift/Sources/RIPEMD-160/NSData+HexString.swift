import Foundation

extension Data {

    public static func fromHexString (_ string: String) -> Data {
        // Based on: http://stackoverflow.com/a/2505561/313633
        let data = NSMutableData()
            
        var temp = ""
        
        for char in string {
            temp += String(char)
            if(temp.count == 2) {
                let scanner = Scanner(string: temp)
                var value: CUnsignedInt = 0
                scanner.scanHexInt32(&value)
                data.append(&value, length: 1)
                temp = ""
            }
            
        }
        
        return data as Data
    }
}

extension NSData {
    
    public static func fromHexString (_ string: String) -> NSData {
        // Based on: http://stackoverflow.com/a/2505561/313633
        let data = NSMutableData()
        
        var temp = ""
        
        for char in string {
            temp += String(char)
            if(temp.count == 2) {
                let scanner = Scanner(string: temp)
                var value: CUnsignedInt = 0
                scanner.scanHexInt32(&value)
                data.append(&value, length: 1)
                temp = ""
            }
            
        }
        
        return data
    }
}
