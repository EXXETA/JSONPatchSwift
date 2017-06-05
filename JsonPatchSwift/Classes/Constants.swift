//
//  Constants.swift
//  Pods
//
//  Created by Maximilian Alexander on 6/4/17.
//
//

import Foundation

public struct Constants {
    
    public struct JsonPatch {
        
        public struct Parameter {public 
            static let Op = "op"
            static let Path = "path"
            static let Value = "value"
            static let From = "from"
        }
        
        public struct InitialisationErrorMessages {
            public static let PatchEncoding = "Could not encode patch."
            public static let PatchWithEmptyError = "Patch array does not contain elements."
            public static let InvalidRootElement = "Root element is not an array of dictionaries or a single dictionary."
            public static let OpElementNotFound = "Could not find 'op' element."
            public static let PathElementNotFound = "Could not find 'path' element."
            public static let InvalidOperation = "Operation is invalid."
            public static let FromElementNotFound = "Could not find 'from' element."
            public static let ValueElementNotFound = "Could not find 'value' element."
        }
        
        public struct ErrorMessages {
            public static let ValidationError = "Could not validate JSON."
        }
        
    }
    
    
    
    public struct Operation {
        static let Add = "add"
        static let Remove = "remove"
        static let Replace = "replace"
        static let Move = "move"
        static let Copy = "copy"
        static let Test = "test"
    }
    
    public struct JsonPointer {
        public static let Delimiter = "/"
        public static let EndOfArrayMarker = "-"
        public static let EmptyString = ""
        public static let EscapeCharacter = "~"
        public static let EscapedDelimiter = "~1"
        public static let EscapedEscapeCharacter = "~0"
    }
    
}
