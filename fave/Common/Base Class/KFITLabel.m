//
//  KFITLabel.m
//  KFIT
//
//  Created by KFIT on 5/20/15.
//  Copyright (c) 2015 kfit. All rights reserved.
//

#import "KFITLabel.h"

@implementation KFITLabel

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    // If this is a multiline label, need to make sure
    // preferredMaxLayoutWidth always matches the frame width
    // (i.e. orientation change can mess this up)
    
    if (self.numberOfLines == 0 && bounds.size.width != self.preferredMaxLayoutWidth) {
        self.preferredMaxLayoutWidth = self.bounds.size.width;
        [self setNeedsUpdateConstraints];
    }
}


- (void)setLineSpacing:(NSNumber *)lineSpacing
{
    NSMutableAttributedString *attributedString;
    if (self.text.length > 0) {
        attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
    }
    if (self.attributedText.length > 0){
        attributedString = [self.attributedText mutableCopy];
    }
    if (attributedString) {
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = lineSpacing.doubleValue;
        style.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:style
                                 range:NSMakeRange(0, self.text.length)];
        self.attributedText = attributedString;
    }
}


- (void)setLetterSpacing:(NSNumber *)letterSpacing
{
    if (self.text.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        [attributedString addAttribute:NSKernAttributeName
                                 value:letterSpacing
                                 range:NSMakeRange(0, self.text.length)];
        self.attributedText = attributedString;
    }
}

- (void)setLineHeightMultiple:(NSNumber *)lineHeightMultiple
{
    if (self.text.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.lineHeightMultiple = lineHeightMultiple.doubleValue;
        style.alignment = NSTextAlignmentCenter;
        [attributedString addAttribute:NSParagraphStyleAttributeName
                                 value:style
                                 range:NSMakeRange(0, self.text.length)];
        self.attributedText = attributedString;
    }
}

- (void)setStrikeThrough:(BOOL) strikeThrough {
    _strikeThrough = strikeThrough;
    if([self.text length] > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        if(_strikeThrough){
            [attributedString addAttribute:NSStrikethroughStyleAttributeName
                                     value:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                     range:NSMakeRange(0, self.text.length)];
        } else {
            [attributedString addAttribute:NSStrikethroughStyleAttributeName
                                     value:[NSNumber numberWithInteger:NSUnderlineStyleNone]
                                     range:NSMakeRange(0, self.text.length)];
        }
        self.attributedText = attributedString;
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if(self.strikeThrough) {
        [self setStrikeThrough:YES];
    }
}

- (void)replacePlaceholder:(NSString *)string withImage:(UIImage *)image {
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.image = image;
    attachment.bounds = CGRectMake(0, (-(image.size.height / 2) - self.font.descender), image.size.width, image.size.height);
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    
    NSMutableAttributedString *attributedString= [[NSMutableAttributedString alloc] initWithString:self.text];
    NSRange placeholderRange = [self.text rangeOfString:string];
    [attributedString replaceCharactersInRange:placeholderRange withAttributedString:attachmentString];
    self.attributedText = attributedString;
}

@end
