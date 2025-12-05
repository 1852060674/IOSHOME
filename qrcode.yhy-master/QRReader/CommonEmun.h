//
//  CommonEmun.h
//  QRReader
//
//  Created by awt on 15/7/20.
//  Copyright (c) 2015年 awt. All rights reserved.
//

#ifndef QRReader_CommonEmun_h
#define QRReader_CommonEmun_h

typedef NS_ENUM(NSInteger, CodeType){
    CTQrCode,
    CTEAN13Code,
    CTEAN8Code,
    CTUPCECode,
    CTWebSite,
    CTApplication,
    CTText,
    CTNone,
};
typedef NS_ENUM(NSInteger, ScannerMode) {
    SMCamera,
    SMHisTory,
    SMAlBum,
    SMImage,
    SMCreator,
    SMPDFMaker,
};
typedef NS_ENUM(NSInteger, AvailableCameraType) {
    ACTFront,
    ACTBack,
    ACTBoth,
    ACTNone,
};
typedef NS_ENUM(NSInteger, PDFEditionMode)
{
    EMDelete,
    EMINsert,
    EMExchange,
    EmHistory,
    EMNone,
};
#endif