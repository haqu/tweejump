/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Leonardo Kasperavičius
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import "CCParticleSystem.h"
#import "ccConfig.h"

@class CCSpriteFrame;

/** CCParticleSystemQuad is a subclass of CCParticleSystem

 It includes all the features of ParticleSystem.
 
 Special features and Limitations:	
  - Particle size can be any float number.
  - The system can be scaled
  - The particles can be rotated
  - On 1st and 2nd gen iPhones: It is only a bit slower that CCParticleSystemPoint
  - On 3rd gen iPhone and iPads: It is MUCH faster than CCParticleSystemPoint
  - It consumes more RAM and more GPU memory than CCParticleSystemPoint
  - It supports subrects
 @since v0.8
 */
@interface CCParticleSystemQuad : CCParticleSystem
{
	ccV2F_C4B_T2F_Quad	*quads_;		// quads to be rendered
	GLushort			*indices_;		// indices
#if CC_USES_VBO
	GLuint				quadsID_;		// VBO id
#endif
}

/** initialices the indices for the vertices */
-(void) initIndices;

/** initilizes the texture with a rectangle measured Points */
-(void) initTexCoordsWithRect:(CGRect)rect;

/** Sets a new CCSpriteFrame as particle.
 WARNING: this method is experimental. Use setTexture:withRect instead.
 @since v0.99.4
 */
-(void)setDisplayFrame:(CCSpriteFrame*)spriteFrame;

/** Sets a new texture with a rect. The rect is in Points.
 @since v0.99.4
 */
-(void) setTexture:(CCTexture2D *)texture withRect:(CGRect)rect;

@end

