//main.swift


import Foundation
import ORSSerial




class SpDel: NSObject, ORSSerialPortDelegate{
    
    init(autoclose: Bool){
        self.autoclose = autoclose
    }
    
    let autoclose: Bool
    
    var serialPort: ORSSerialPort? {
        didSet {
            serialPort?.delegate = self;
            serialPort?.open()
        }
    }
    
    
    // ORSSerialPortDelegate
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        if let string = NSString(data: data, encoding: String.Encoding.ascii.rawValue) {
            print(string)
            if autoclose{
                serialPort.close()
                exit(0)
            }
        } else {
            print("Failed to decode data")
        }
       
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        self.serialPort = nil
        serialPort.close()
        exit(-2)
        
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port (\(serialPort)) encountered error: \(error)")
        serialPort.close()
        exit(-1)
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        //print("Serial port \(serialPort) was opened", terminator: "")
    }
}


if CommandLine.arguments.count < 3{
    print("Invalid input")
    exit(-5)
}

let path = CommandLine.arguments[1]
let command = CommandLine.arguments[2]
let keepalive = CommandLine.arguments.contains("-k")

guard let serialPort = ORSSerialPort(path: path) else {
    print("Failed to Create Serial Port")
    exit(-3)
}

serialPort.baudRate = 115200

let del = SpDel(autoclose: !keepalive)
del.serialPort = serialPort
serialPort.send(command.data(using: .ascii)!)
//serialPort.send("AT+DEVCONINFO".data(using: .ascii)!)
let timeout = Date() + 10
RunLoop.current.run(until: timeout)
serialPort.close()
exit(-4)

