//
//  ViewController.m
//  HSF_WallpaperMaker
//
//  Created by StarSky_MacBook Pro on 2019/6/12.
//  Copyright © 2019 StarSky_MacBook Pro. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *myImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

UIImageView* contentOfIamge;
UIImage*     fakeImage;

float imageOffset_X = 0.0;
float imageOffset_X_All= 0.00001;
float imageOffset_Y= 0.0;
float imageOffset_Y_All= 0.00001;

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage* image = [UIImage imageNamed:@"aim.JPG"];//默认图片
    fakeImage = image;//全局唯一剪切图片
    
    
    //自适应能够左右还是前后滑动
    if( (float)image.size.width /(float)200 >  (float)image.size.height /(float)433)
    {
        contentOfIamge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 433 * ((float)image.size.width / (float)image.size.height), 433)];//设置滑动宽度
        
        imageOffset_X_All = 433.0 * ((float)image.size.width / (float)image.size.height);
    }
    else
    {
        contentOfIamge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200 * ((float)image.size.height / (float)image.size.width))];//设置滑动长度
        imageOffset_Y_All = 200.0 * ((float)image.size.height / (float)image.size.width);
    }
 //NSLog(@"这个目前剪切的图片的大小是：%f,%f",contentOfIamge.bounds.size.width,contentOfIamge.bounds.size.height);
    _scrollView.contentSize = contentOfIamge.bounds.size;
    //contentOfIamge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    contentOfIamge.image = image;
    [_scrollView addSubview:contentOfIamge];
    
}
- (UIImage *)addImage:(UIImage *)image1 withImage:(NSString *)imageName2{
    
    //UIImage *image1 = [UIImage imageNamed:imageName1];
    UIImage *image2 = [UIImage imageNamed:imageName2];
    //    UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"222.png" ofType:nil]];//这个方法不会缓存
    
    UIGraphicsBeginImageContext(image2.size);
    
    //可以优化部分，某些情况会压缩总的缩略图，但是滑动一丁点就等使用正确的办法
    if (imageOffset_Y > imageOffset_X) {
        NSLog(@"上下的移动,得到的百分比是：%f",imageOffset_Y / imageOffset_Y_All);
        float offset_pesent = imageOffset_Y / imageOffset_Y_All;
        
        //剪切操作
        CGImageRef sourceImageRef = [image1 CGImage];//获取需要的剪切的原始图片
        CGRect rect = CGRectMake(0,image1.size.height*offset_pesent, image1.size.width, image1.size.width * (image2.size.height / image2.size.width));//设置剪切后的图像区域
        NSLog(@"打算剪切的位置大小是: %@", NSStringFromCGRect(rect));
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);//按照给定的矩形区域进行剪裁
        UIImage *newImage = [UIImage imageWithCGImage:newImageRef];//转换成能使用的UIImage
        
        UIGraphicsBeginImageContext(image2.size);  //size 为CGSize类型，即你所需要的图片尺寸,在你的蒙版h上面绘制图像
        [newImage drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];//将剪切得到的图像 画在画布上
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();//得到当前的图像
        CGImageRelease(newImageRef);//释放内存
        UIGraphicsEndImageContext();//关闭第二个
        
        UIGraphicsEndImageContext();//关闭第一个
        
        return scaledImage;   //返回的就是已经改变的图片
    }
    else
    {
        NSLog(@"左右的移动,得到的百分比是：%f",imageOffset_X / imageOffset_X_All);
        float offset_pesent = imageOffset_X / imageOffset_X_All;
        //剪切操作
        CGImageRef sourceImageRef = [image1 CGImage];
        CGRect rect = CGRectMake(image1.size.width*offset_pesent, 0, image1.size.height *(image2.size.width / image2.size.height), image1.size.height);
        NSLog(@"打算剪切的大小是: %@", NSStringFromCGRect(rect));
        CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);//按照给定的矩形区域进行剪裁
        UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
        
        UIGraphicsBeginImageContext(image2.size);  //size 为CGSize类型，即你所需要的图片尺寸
        [newImage drawInRect:CGRectMake(0, 0, image2.size.width, image2.size.height)];
        UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        CGImageRelease(newImageRef);
        UIGraphicsEndImageContext();
        
        UIGraphicsEndImageContext();
        return scaledImage;   //返回的就是已经改变的图片
    }
}
//获得滑动的值
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"%f",scrollView.contentOffset.x);
    imageOffset_X = scrollView.contentOffset.x;
    imageOffset_Y = scrollView.contentOffset.y;
}

- (IBAction)SaveAndDraw:(id)sender {
    //显示并且保存到手机
     _myImage.image = [self addImage:fakeImage withImage:@"line.PNG"];
    UIImageWriteToSavedPhotosAlbum(_myImage.image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
    
}
- (IBAction)SelectImage:(id)sender {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //优化 提示已经保存
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [contentOfIamge removeFromSuperview];//刷新获取得到的View视图
    //You can retrieve the actual UIImage
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //Or you can get the image url from AssetsLibrary
    //NSURL *path = [info valueForKey:UIImagePickerControllerReferenceURL];
    NSLog(@"相册得到的图片的是：%f,%f",image.size.width,image.size.height);
    if( (float)image.size.width /(float)200 >  (float)image.size.height /(float)433)
    {
        contentOfIamge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 433 * ((float)image.size.width / (float)image.size.height), 433)];
        imageOffset_X_All = 433.0 * ((float)image.size.width / (float)image.size.height);
    }
    else
    {
        contentOfIamge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200 * ((float)image.size.height / (float)image.size.width))];
        imageOffset_Y_All = 200.0 * ((float)image.size.height / (float)image.size.width);
    }
    //NSLog(@"这个目前剪切的图片的大小是：%f,%f",contentOfIamge.bounds.size.width,contentOfIamge.bounds.size.height);
    _scrollView.contentSize = contentOfIamge.bounds.size;
    //contentOfIamge = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    contentOfIamge.image = image;
    [_scrollView addSubview:contentOfIamge];
    fakeImage = image;
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
