//
//  RemoteAnalysisFilter.m
//  RemoteAnalysis
//
//  Created by davidcox 2017-02-19
//  Copyright (c) 2017 DeepHealth. All rights reserved.
//

#import "RemoteAnalysisFilter.h"

#import <zmq.h>

#import "MammogramHeader.pbobjc.h"


@implementation RemoteAnalysisFilter

- (long) filterImage:(NSString*) menuName
{
	long			i, x, z;
	float			*fImage;
	unsigned char   *rgbImage;

    // Set up a 0mq socket
    void *context = zmq_ctx_new();
    void *requester = zmq_socket (context, ZMQ_REQ);
    zmq_connect (requester, "tcp://localhost:5555");
    
	// Display a waiting window
	id waitWindow = [viewerController startWaitWindow:@"Analyzing..."];
	
	for( z = 0; z < [viewerController maxMovieIndex]; z++)
	{
		// Contains a list of DCMPix objects: they contain the pixels of current series
		NSArray		*pixList = [viewerController pixList: z];		
		DCMPix		*curPix;
		
		// Loop through all images contained in the current series
		//for( i = 0; i < [pixList count]; i++)
        for(i = 0; i < 1; i++)
        {
			curPix = [pixList objectAtIndex: i];
			
			if( i == [[viewerController imageView] curImage])
			{
				NSLog(@"Cool, this is the image (%ld) currently displayed!", i);
			}
			
			// fImage is a pointer on the pixels, ALWAYS represented in float (float*) or in ARGB (unsigned char*) 
			
            // Prepare a protocol buffer to send image info
            MammogramHeader *imageHeader = [[MammogramHeader alloc] init];
            [imageHeader setWidth:(int32_t)[curPix pwidth]];
            [imageHeader setHeight:(int32_t)[curPix pheight]];
            [imageHeader setImageId:@"test"];
            
            long image_data_size = [curPix pwidth] * [curPix pheight];
            
            if([curPix isRGB]){
                [imageHeader setImtype:ImageType_Rgb];
                image_data_size *= 3;
                
            } else {
                [imageHeader setImtype:ImageType_Float32];
                image_data_size *= sizeof(float);
            }
            

            // Serialize the image header
            NSData *imageHeaderData = [imageHeader data];
            
            // pack and send the image header info
            NSUInteger len = [imageHeaderData length];
            Byte *byteData = (Byte*)malloc(len);
            memcpy(byteData, [imageHeaderData bytes], len);
            
            int err;
            
            // send header
            err = zmq_send(requester, byteData, len, ZMQ_SNDMORE);
            
            // todo: check err
            
            // send image
            err = zmq_send(requester, (unsigned char *)[curPix fImage], image_data_size, 0);
            
            // todo: check err
            
            // receive a message back from the server
            char buffer [10];
            zmq_recv (requester, buffer, 10, 0);
            NSLog(@"Received Response\n");

        }
	}
	
    
    zmq_close (requester);
    zmq_ctx_destroy (context);
    
	// Close the waiting window
	[viewerController endWaitWindow: waitWindow];
		
	return 0;   // No Errors
}

@end
