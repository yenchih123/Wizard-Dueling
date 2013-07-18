/*
 * Kobold2D™ --- http://www.kobold2d.org
 *
 * Copyright (c) 2010-2011 Steffen Itterheim. 
 * Released under MIT License in Germany (LICENSE-Kobold2D.txt).
 */

#import "DuelLayer.h"
#import "EnvironmentalObject.h"
#import "Wizard.h"

@interface DuelLayer (PrivateMethods)
@end

#define HEIGHT_WINDOW 320
#define WIDTH_WINDOW 480
#define AMOUNT_OF_OBJECTS 10
#define AMOUNT_OF_HEAVY 3
#define AMOUNT_OF_MEDIUM 3
#define AMOUNT_OF_LIGHT 4
#define AMOUNT_OF_ATTACKS_CHOSEN 4
int attackCounter = 0;
int oneMax = 4;
int twoMax = 4;
BOOL outOfMoves = false;
BOOL attackAlreadyChosen = false;
BOOL onesturn = true;
BOOL objectSelected = false;
BOOL oneChosen = false;
BOOL twoChosen = false;
BOOL attackTied = false;
BOOL healthUpdated = true;
BOOL turnUpdated = true;
BOOL resistanceUpdated = true;
BOOL countUpdated = true;
BOOL oneWon = false;
NSMutableArray* allObjects;
NSMutableArray* boundingBoxArray;
Wizard* one;
Wizard* two;
CCLabelTTF *turnLabel;
int oneChosenIndex;
int twoChosenIndex;
EnvironmentalObject* oneChosenObject;
EnvironmentalObject* twoChosenObject;
int chosenIndex;
CCLabelTTF* fireLabel;
CCLabelTTF* iceLabel;
CCLabelTTF* electricLabel;
CCLabelTTF* oneHealthLabel;
CCLabelTTF* twoHealthLabel;
CCLabelTTF* restartLabel;
CCLabelTTF* finishLabel;
CCLabelTTF* oneFireResistance;
CCLabelTTF* oneIceResistance;
CCLabelTTF* oneElectricResistance;
CCLabelTTF* twoFireResistance;
CCLabelTTF* twoIceResistance;
CCLabelTTF* twoElectricResistance;
CCLabelTTF* countLabel;
CCLabelTTF* oneWinLabel;
CCLabelTTF* twoWinLabel;
CCSprite* oneFireElement;
CCSprite* oneIceElement;
CCSprite* oneElectricElement;
CCSprite* twoFireElement;
CCSprite* twoIceElement;
CCSprite* twoElectricElement;
CCSprite* bigChosenImage;
CCSprite* mediumChosenImage;
CCSprite* smallChosenImage;
NSMutableArray* haveChosen;
NSMutableArray* oneAttacks;
NSMutableArray* twoAttacks;
NSMutableArray* attackSequence;
@implementation DuelLayer

-(id) init
{
  if ((self = [super init]))
	{

        
        CGSize winSize = [[CCDirector sharedDirector] winSize];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EnvironmentalObjects" ofType:@"plist"];
        NSDictionary *EnvironmentalObjects = [NSDictionary dictionaryWithContentsOfFile:path];
        allObjects = [[NSMutableArray alloc] init];
        haveChosen = [[NSMutableArray alloc] init];
        oneAttacks = [[NSMutableArray alloc] init];
        twoAttacks = [[NSMutableArray alloc] init];
        [self refreshObjects];
        CCLabelTTF* objectTutorial = [CCLabelTTF labelWithString:@"Choose Object to Attack With" dimensions:CGSizeMake(180,60) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        objectTutorial.position = ccp(360, 225);
        objectTutorial.color = ccBLACK;
        
        restartLabel= [CCLabelTTF labelWithString:@"Restart???" dimensions:CGSizeMake(180,60) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        restartLabel.color = ccBLACK;
        restartLabel.position = ccp(-9001,-9001);
        
        fireLabel = [CCLabelTTF labelWithString:@"Emblaze" dimensions:CGSizeMake(70,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        iceLabel = [CCLabelTTF labelWithString:@"Freeze" dimensions:CGSizeMake(50,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        electricLabel = [CCLabelTTF labelWithString:@"Electrocute" dimensions:CGSizeMake(90,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        
        finishLabel= [CCLabelTTF labelWithString:@"End Turn" dimensions:CGSizeMake(180,60) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        finishLabel.position = ccp(360, 150);
        finishLabel.color = ccGREEN;

        //INITIALIZE AND POSITION WIZARDS
        one = [[Wizard alloc] initWithFile:@"WhiteGhost.png"];
        two = [[Wizard alloc] initWithFile:@"RedGhost.png"];
        one.position = ccp(WIDTH_WINDOW/4, 50);
        two.position = ccp(WIDTH_WINDOW/2 + WIDTH_WINDOW/4, 50);
        
        //INITIALIZE affinity element sprites
        oneFireElement = [[CCSprite alloc] initWithFile:@"Fire.png"];
        twoFireElement = [[CCSprite alloc] initWithFile:@"Fire.png"];
        oneIceElement = [[CCSprite alloc] initWithFile:@"ice.png"];
        twoIceElement = [[CCSprite alloc] initWithFile:@"ice.png"];
        oneElectricElement = [[CCSprite alloc] initWithFile:@"lightning.png"];
        twoElectricElement = [[CCSprite alloc] initWithFile:@"lightning.png"];
        oneFireElement.visible = false;
        twoFireElement.visible = false;
        oneIceElement.visible = false;
        twoIceElement.visible = false;
        oneElectricElement.visible = false;
        twoElectricElement.visible = false;
        oneFireElement.position = one.position;
        oneIceElement.position = one.position;
        oneElectricElement.position = one.position;
        twoFireElement.position = two.position;
        twoIceElement.position = two.position;
        twoElectricElement.position = two.position;
        
        //INITIALIZE CHOSEN IMAGE ICON
        bigChosenImage = [[CCSprite alloc] initWithFile:@"bigChosen.png"];
        bigChosenImage.position = ccp(-9001, -9001);
        mediumChosenImage = [[CCSprite alloc] initWithFile:@"mediumChosen.png"];
        mediumChosenImage.position = ccp(-9001, -9001);
        smallChosenImage = [[CCSprite alloc] initWithFile:@"smallChosen.png"];
        smallChosenImage.position = ccp(-9001, -9001);

        //CREATE BACKGROUND
        CCSprite *bg = [CCSprite spriteWithFile:@"whitebackground.png"];
        bg.position = ccp(winSize.width/2, winSize.height/2);
        CCLayer *bgLayer = [CCLayer node];
        [bgLayer addChild :bg z:0];
        
        [self addChild:restartLabel z:3];
        [self addChild:finishLabel z:3];
        [self addChild: one z:2];
        [self addChild: two z:2];
        [self addChild: bgLayer];
        //[self addChild: objectTutorial];
        [self scheduleUpdate];
        [self addChild:oneFireElement z:1];
        [self addChild:oneIceElement z: 1];
        [self addChild:oneElectricElement z:1];
        [self addChild:twoFireElement z:1];
        [self addChild:twoIceElement z:1];
        [self addChild:twoElectricElement z:1];
        [self addChild:bigChosenImage z:1];
        [self addChild:mediumChosenImage z:1];
        [self addChild:smallChosenImage z:1];

	}
	return self;
}
//Refills Array of environmental objects
-(void)refreshObjects
{
    for(int i = 0; i < AMOUNT_OF_LIGHT; i++)
    {
        EnvironmentalObject *object = [[EnvironmentalObject alloc] initWithType: 0];
        object.position = CGPointMake( 60 + i * WIDTH_WINDOW/10, HEIGHT_WINDOW - 50);
        object.anchorPoint = ccp(0.5, 0.5);
        [allObjects addObject: object];
        CCSprite* small = [[CCSprite alloc] initWithFile:@"haveSmallChosen.png"];
        small.position = object.position;
        small.visible = false;
        [haveChosen addObject: small];
        [self addChild:object z:2];
        [self addChild:small z:1];
    }
    for(int i = 0; i < AMOUNT_OF_MEDIUM; i++)
    {
        EnvironmentalObject *object = [[EnvironmentalObject alloc] initWithType: 1];
        object.position = CGPointMake( WIDTH_WINDOW/2 + 20 + i * (WIDTH_WINDOW/10 + 5), HEIGHT_WINDOW - 50);
        object.anchorPoint = ccp(0.5, 0.5);
        [allObjects addObject: object];
        CCSprite* medium = [[CCSprite alloc] initWithFile:@"haveMediumChosen.png"];
        medium.position = object.position;
        medium.visible = false;
        [haveChosen addObject: medium];
        [self addChild:object z:2];
        [self addChild:medium z:1];
    }
    for(int i = 0; i < AMOUNT_OF_HEAVY; i++)
    {
        EnvironmentalObject *object = [[EnvironmentalObject alloc] initWithType: 2];
        object.position = CGPointMake( 60 + i * (WIDTH_WINDOW/10 + 20), HEIGHT_WINDOW - 115);
        object.anchorPoint = ccp(0.5, 0.5);
        CCSprite* big = [[CCSprite alloc] initWithFile:@"haveLargeChosen.png"];
        big.position = object.position;
        big.visible = false;
        [allObjects addObject: object];
        [haveChosen addObject:big];
        [self addChild:object z:2];
        [self addChild: big z:1];
    }
}
//compare two attacks
-(void) compareFirstAttack: (EnvironmentalObject*)first
withSecondSttack: (EnvironmentalObject*)second
{
    if(first != nil || second != nil)
    {

        CGPoint oneOriginalPosition = first.position;
        CGPoint twoOriginalPosition = second.position;
        
        first.position = ccp(WIDTH_WINDOW/4, HEIGHT_WINDOW/2);
        second.position = ccp(WIDTH_WINDOW/2 + WIDTH_WINDOW/4, HEIGHT_WINDOW/2);
        /*
        [first runAction: [CCMoveTo actionWithDuration:.5 position:ccp(WIDTH_WINDOW/2, HEIGHT_WINDOW/2)]];
        [second runAction: [CCMoveTo actionWithDuration:.5 position:ccp(WIDTH_WINDOW/2, HEIGHT_WINDOW/2)]];
         */
        while (first.position.x != WIDTH_WINDOW/2 && second.position.x != WIDTH_WINDOW/2 && first.position.y != HEIGHT_WINDOW/2 && second.position.y != HEIGHT_WINDOW/2)
        {
            
        }
        first.position = oneOriginalPosition;
        second.position = twoOriginalPosition;

        
        //DETERMINE WHO ATTACKS FIRST DEPENDING ON TYPE
        if(first.type < second.type)
        {
            [self doDamage:first toPlayer:two byAttacker: one];
            [self doDamage:second toPlayer:one byAttacker:two];
        }
        else if(first.type == second.type)
        {
            if(first.emblazed && second.electrified)
            {
                [self doDamage:first toPlayer:two byAttacker: one];
                [self doDamage:second toPlayer:one byAttacker:two];
            }
            else if(first.electrified && second.frozen)
            {
                [self doDamage:first toPlayer:two byAttacker:one];
                [self doDamage:second toPlayer:one byAttacker:two];
            }
            else if(first.frozen && second.emblazed)
            {
                [self doDamage:first toPlayer:two byAttacker:one];
                [self doDamage:second toPlayer:one byAttacker:two];
            }
            else if(first.emblazed && second.frozen)
            {
                [self doDamage:second toPlayer:one byAttacker:two];
                [self doDamage:first toPlayer:two byAttacker:one];
            }
            else if(first.electrified && second.emblazed)
            {
                [self doDamage:second toPlayer:one byAttacker: two];
                [self doDamage:first toPlayer:two byAttacker:one];
            }
            else if(first.frozen && second.electrified)
            {
                [self doDamage:second toPlayer:one byAttacker: two];
                [self doDamage:first toPlayer:two byAttacker: one];
            }
            //DETERMINE WHEN ATTACKS ARE EXACTLY THE SAME
            else if(first.emblazed && second.emblazed)
            {
                one.health = one.health - 10;
                two.health = two.health - 10;
                NSLog(@"Attacks completely tied");
                healthUpdated = true;
                NSLog(@"Health removed");
                [self removeChild: oneHealthLabel];
                [self removeChild: twoHealthLabel];
            }
            else if(first.frozen && second.frozen)
            {
                one.health = one.health - 10;
                two.health = two.health - 10;
                NSLog(@"Attacks completely tied");
                healthUpdated = true;
                NSLog(@"Health removed");
                [self removeChild: oneHealthLabel];
                [self removeChild: twoHealthLabel];
            }
            else if(first.electrified && second.electrified)
            {
                one.health = one.health - 10;
                two.health = two.health - 10;
                NSLog(@"Attacks completely tied");
                healthUpdated = true;
                NSLog(@"Health removed");
                [self removeChild: oneHealthLabel];
                [self removeChild: twoHealthLabel];
            }
            else{
                NSLog(@"Something's not right...");
            }
            attackTied = true;
        }
        else
        {
            [self doDamage:second toPlayer:one byAttacker:two];
            [self doDamage:first toPlayer:two byAttacker: one];
        }
    }
}
-(void) wizardAttribute: (Wizard*) aWizard
{

    if([aWizard isEqual:one])
    {
        if(aWizard.flame)
        {
            oneFireElement.visible = true;
            oneIceElement.visible = false;
            oneElectricElement.visible = false;
        }
        else if(aWizard.ice)
        {

            oneFireElement.visible = false;
            oneIceElement.visible = true;
            oneElectricElement.visible = false;
        }
        else if(aWizard.electric)
        {
            oneFireElement.visible = false;
            oneIceElement.visible = false;
            oneElectricElement.visible = true;
        }
    }
    else
    {
        if(aWizard.flame)
        {
            twoFireElement.visible = true;
            twoIceElement.visible = false;
            twoElectricElement.visible = false;
        }
        else if(aWizard.ice)
        {
            
            twoFireElement.visible = false;
            twoIceElement.visible = true;
            twoElectricElement.visible = false;
        }
        else if(aWizard.electric)
        {
            twoFireElement.visible = false;
            twoIceElement.visible = false;
            twoElectricElement.visible = true;
        }
    }

}
-(void) update:(ccTime)delta
{
    KKInput* input = [KKInput sharedInput];
    CGPoint pos = [input locationOfAnyTouchInPhase:KKTouchPhaseBegan];

    //ADDING HEALTH BARS
    NSString* oneHealth = [NSString stringWithFormat: @"Health: %d", one.health];
    NSString* twoHealth = [NSString stringWithFormat:@"Health: %d", two.health];
    if(healthUpdated)
    {
    oneHealthLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",oneHealth] dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:24];
    oneHealthLabel.color = ccBLACK;
    twoHealthLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@",twoHealth] dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:24];
    twoHealthLabel.color = ccBLACK;
    oneHealthLabel.position = ccp(120,300);
    twoHealthLabel.position = ccp(360,300);

    [self addChild: oneHealthLabel];
    [self addChild: twoHealthLabel];
        healthUpdated = false;
    }
    //ADDING ATTACK COUNTER
    if(countUpdated)
    {
        if(onesturn)
        {
            countLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Attacks left: %d",oneMax] dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        }
        else
        {
            countLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"Attacks left: %d",twoMax] dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        }
        countLabel.color = ccBLACK;
        countLabel.position = ccp(450, 170);
        [self addChild:countLabel];
        countUpdated = false;
    }

    //DISPLAYING BOTH PLAYER'S RESISTANCE BAR
    if(resistanceUpdated)
    {
    NSString* oneFireStat = [NSString stringWithFormat:@"Fire Resistance: %d", one.fireResistance];
    NSString* oneIceStat = [NSString stringWithFormat: @"Ice Resistance: %d", one.iceResistance];
    NSString* oneElectricStat = [NSString stringWithFormat: @"Electric Resistance: %d", one.electricResistance];
    NSString* twoFireStat = [NSString stringWithFormat:@"Fire Resistance: %d", two.fireResistance];
    NSString* twoIceStat = [NSString stringWithFormat: @"Ice Resistance: %d", two.iceResistance];
    NSString* twoElectricStat = [NSString stringWithFormat: @"Electric Resistance: %d", two.electricResistance];
    oneFireResistance = [CCLabelTTF labelWithString:oneFireStat dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:14];
    oneFireResistance.position = ccp(120, 120);
    oneFireResistance.color = ccBLACK;
    oneIceResistance = [CCLabelTTF labelWithString:oneIceStat dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:14];
    oneIceResistance.position = ccp(120,110);
    oneIceResistance.color = ccBLACK;
    oneElectricResistance = [CCLabelTTF labelWithString:oneElectricStat dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:14];
    oneElectricResistance.position = ccp(120, 100);
    oneElectricResistance.color = ccBLACK;
    twoFireResistance = [CCLabelTTF labelWithString:twoFireStat dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:14];
    twoFireResistance.position = ccp(330, 120);
    twoFireResistance.color = ccBLACK;
    twoIceResistance = [CCLabelTTF labelWithString:twoIceStat dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:14];
    twoIceResistance.position = ccp(330, 110);
    twoIceResistance.color = ccBLACK;
    twoElectricResistance = [CCLabelTTF labelWithString:twoElectricStat dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:14];
    twoElectricResistance.position = ccp(330, 100);
    twoElectricResistance.color = ccBLACK;
        NSLog(@"resistance updated");
    [self addChild:oneFireResistance z:2];
    [self addChild:oneIceResistance z: 2];
    [self addChild:oneElectricResistance z:2];
    [self addChild:twoFireResistance z:2];
    [self addChild:twoIceResistance z:2];
    [self addChild:twoElectricResistance z:2];
        resistanceUpdated = false;
    }
    
    //DETERMINES IF FINISH BUTTON WAS CLICKED OR NOT
    CGRect finishBound = [finishLabel boundingBox];
    if(CGRectContainsPoint(finishBound, pos))
    {
        [self nextTurn];
    }
    
    //DISPLAYING WHOSE TURN IT IS
    NSString* turnString;
    if(onesturn)
    {
        turnString = @"Player One's turn";
    }
    else{
        turnString = @"Player Two's turn";
    }
    if(turnUpdated)
    {
    turnLabel = [CCLabelTTF labelWithString:turnString dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
    turnLabel.position = ccp(360, 200);
    turnLabel.color = ccBLACK;

    [self addChild: turnLabel];
        turnUpdated = false;
    }
    
    
    //Copy of array of all the objects
    NSMutableArray* tempArray = [allObjects copy];
    if(input.anyTouchBeganThisFrame)
    {
        for(int i = 0; i < AMOUNT_OF_OBJECTS; i++)
        {
            //CREATES BOUNDING BOX FOR EACH OBJECT AND CHECKS THEM
            EnvironmentalObject* testObject = [tempArray objectAtIndex:i];
            CGRect objectBound = [testObject boundingBox];
            if(CGRectContainsPoint(objectBound, pos)
               //&&!objectSelected
               )
            {
                chosenIndex = i;
                //CHECKS IF OBJECT HAS ALREADY BEEN CHOSEN
                
                if(onesturn)
                {
                    int originalMax = oneMax;
                    for(int i = 0; i < originalMax - oneMax; i++)
                    {
                        if([[tempArray objectAtIndex:chosenIndex] isEqual: [oneAttacks objectAtIndex:i]])
                        {
                            attackAlreadyChosen = true;
                        }
                    }
                }
                else
                {
                    int originalMax = twoMax;
                    for(int i = 0; i < originalMax - twoMax; i++)
                    {
                        if([[tempArray objectAtIndex:chosenIndex] isEqual: [twoAttacks objectAtIndex:i]])
                        {
                            attackAlreadyChosen = true;
                        }
                    }
                }
                //CHECKS IF THE PLAYER HAS ANY MOVES LEFT
                if(onesturn)
                {
                    if(oneMax <= 0)
                    {
                        outOfMoves = true;
                    }
                }
                else
                {
                    if(twoMax <= 0)
                    {
                        outOfMoves = true;
                    }
                }
                fireLabel.position = ccp(120, 50);
                fireLabel.anchorPoint = ccp(0.5,0.5);
                fireLabel.color = ccRED;

                iceLabel.position = ccp(240, 50);
                iceLabel.anchorPoint = ccp(0.5,0.5);
                iceLabel.color = ccBLUE;
                
                electricLabel.position = ccp(360, 50);
                electricLabel.anchorPoint = ccp(0.5,0.5);
                electricLabel.color = ccYELLOW;
                if(!objectSelected && !attackAlreadyChosen && !outOfMoves)
                {
                objectSelected = true;
                [self addChild:fireLabel z:2];
                [self addChild:iceLabel z:2];
                [self addChild:electricLabel z:2];
                }
                else if(attackAlreadyChosen)
                {
                    NSLog(@"Attack already chosen");
                    attackAlreadyChosen = false;
                }
                else if(outOfMoves)
                {
                    NSLog(@"Out of moves");
                    outOfMoves = false;
                }
            }
        }
        //ADD ENCHANTMENT AFTER OBJECT HAS BEEN SELECTED
        if(objectSelected)
        {
            
            EnvironmentalObject* chosenObject = [tempArray objectAtIndex:chosenIndex];

                if(chosenObject.type == 0)
                {
                    smallChosenImage.position = chosenObject.position;
                    mediumChosenImage.position = ccp(-9001, -9001);
                    bigChosenImage.position = ccp(-9001,-9001);
                }
                else if(chosenObject.type ==1)
                {
                    mediumChosenImage.position = chosenObject.position;
                    smallChosenImage.position = ccp(-9001,-9001);
                    bigChosenImage.position = ccp(-9001,-9001);
                }
                else
                {
                    bigChosenImage.position = chosenObject.position;
                    smallChosenImage.position = ccp(-9001,-9001);
                    mediumChosenImage.position = ccp(-9001,-9001);
                }
            
            CCLabelTTF* elementTutorial = [CCLabelTTF labelWithString:@"Enchant Object with element" dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:16];
            elementTutorial.position = ccp(WIDTH_WINDOW/2, 75);
            elementTutorial.color = ccBLACK;
            //[self addChild: elementTutorial];
            if(onesturn)
            {
                oneChosenObject = [allObjects objectAtIndex:chosenIndex];

            }
            else
            {
                twoChosenObject = [allObjects objectAtIndex:chosenIndex];
            }
            //ADDS BOUND FOR ELEMENT "BUTTONS"
            CGRect fireBound = [fireLabel boundingBox];
            CGRect iceBound = [iceLabel boundingBox];
            CGRect electricBound = [electricLabel boundingBox];
            //Check if player chose emblaze
            if(CGRectContainsPoint(fireBound, pos))
            {
                NSLog(@"Object emblazed");
                if(onesturn)
                {
                    oneChosenObject.frozen = false;
                    oneChosenObject.emblazed = true;
                    oneChosenObject.electrified = false;
                    [oneAttacks addObject:oneChosenObject];

                }
                else
                {
                    twoChosenObject.frozen = false;
                    twoChosenObject.emblazed = true;
                    twoChosenObject.electrified = false;
                    [twoAttacks addObject:twoChosenObject];
                }
                CCSprite* chosen = [haveChosen objectAtIndex:chosenIndex];
                chosen.visible = true;
                bigChosenImage.position = ccp(-9001, -9001);
                smallChosenImage.position = ccp(-9001,-9001);
                mediumChosenImage.position = ccp(-9001,-9001);
                objectSelected = false;
                if(onesturn)
                {
                    oneMax--;
                }
                else
                {
                    twoMax--;
                }
                countUpdated = true;
                [self removeChild:countLabel];
                [self removeChild:fireLabel];
                [self removeChild:iceLabel];
                [self removeChild:electricLabel];
                [self removeChild:elementTutorial];
               // [self nextTurn];
            }
            //check if player chose freeze
            else if(CGRectContainsPoint(iceBound, pos))
            {
                NSLog(@"Object frozen");
                if(onesturn)
                {
                    oneChosenObject.frozen = true;
                    oneChosenObject.emblazed = false;
                    oneChosenObject.electrified = false;
                    [oneAttacks addObject:oneChosenObject];
                }
                else{
                    twoChosenObject.frozen = true;
                    twoChosenObject.emblazed = false;
                    twoChosenObject.electrified = false;
                    [twoAttacks addObject:twoChosenObject];

                }
                CCSprite* chosen = [haveChosen objectAtIndex:chosenIndex];
                chosen.visible = true;
                bigChosenImage.position = ccp(-9001, -9001);
                smallChosenImage.position = ccp(-9001,-9001);
                mediumChosenImage.position = ccp(-9001,-9001);
                objectSelected = false;
                if(onesturn)
                {
                    oneMax--;
                }
                else
                {
                    twoMax--;
                }
                countUpdated = true;
                [self removeChild:countLabel];
                [self removeChild:fireLabel];
                [self removeChild:iceLabel];
                [self removeChild:electricLabel];
                //[self nextTurn];
                [self removeChild:elementTutorial];
            }
            //check if player chose electrocute
            else if(CGRectContainsPoint(electricBound, pos))
            {
                NSLog(@"Object electrified");
                if(onesturn)
                {
                    oneChosenObject.frozen = false;
                    oneChosenObject.emblazed = false;
                    oneChosenObject.electrified = true;
                    [oneAttacks addObject:oneChosenObject];
                    
                }
                else
                {
                    twoChosenObject.frozen = false;
                    twoChosenObject.emblazed = false;
                    twoChosenObject.electrified = true;
                    [twoAttacks addObject:twoChosenObject];
                }
                CCSprite* chosen = [haveChosen objectAtIndex:chosenIndex];
                chosen.visible = true;
                bigChosenImage.position = ccp(-9001, -9001);
                smallChosenImage.position = ccp(-9001,-9001);
                mediumChosenImage.position = ccp(-9001,-9001);
                objectSelected = false;
                if(onesturn)
                {
                    oneMax--;
                }
                else
                {
                    twoMax--;
                }
                countUpdated = true;
                [self removeChild:countLabel];
                [self removeChild:fireLabel];
                [self removeChild:iceLabel];
                [self removeChild:electricLabel];
                [self removeChild:elementTutorial];
            }
        }
    }
    if(oneChosen && twoChosen)
    {
        NSLog(@"Attacks compared");
       // if(oneAttacks.count < AMOUNT_OF_ATTACKS_CHOSEN || twoAttacks.count < AMOUNT_OF_ATTACKS_CHOSEN)
        //{
            int a = oneAttacks.count;
            int b = twoAttacks.count;
            if(oneAttacks.count < twoAttacks.count)
            {
                for(int i = 0; i < a; i++)
                {
                    [self compareFirstAttack:[oneAttacks objectAtIndex:i] withSecondSttack:[twoAttacks objectAtIndex:i]];

                }
                int difference = b - a;
                for(int i = 0; i < difference; i++)
                {
                    [self doDamage:[twoAttacks objectAtIndex:(oneAttacks.count + i)] toPlayer:one byAttacker:two];
                }
            }
            else
            {

                for(int i = 0; i < b; i++)
                {
                    [self compareFirstAttack:[oneAttacks objectAtIndex:i] withSecondSttack:[twoAttacks objectAtIndex:i]];
                }
                int difference = a - b;
                for(int i = 0; i < difference; i++)
                {
                    [self doDamage:[oneAttacks objectAtIndex:(twoAttacks.count + i)] toPlayer:two byAttacker:one];
                }
            }
        //}
        /*
        else
        {
            for(int i = 0; i < AMOUNT_OF_ATTACKS_CHOSEN; i++)
            {
                [self compareFirstAttack:[oneAttacks objectAtIndex:i] withSecondSttack:[twoAttacks objectAtIndex:i]];
            }
        }
         */
        [oneAttacks removeAllObjects];
        [twoAttacks removeAllObjects];
        oneChosen = false;
        twoChosen = false;
        oneMax = oneMax + 2;
        twoMax = twoMax + 2;
        countUpdated = true;
        [self removeChild:countLabel];
    }
    bool oneWon = false;
    if(one.health <= 0)
    {
        oneWon = true;
        one.health = 0;
        oneWinLabel = [CCLabelTTF labelWithString:@"Player Two Wins!!!" dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        oneWinLabel.position = ccp(WIDTH_WINDOW/2, HEIGHT_WINDOW/2);
        oneWinLabel.color = ccBLACK;
        
        restartLabel.position = ccp(WIDTH_WINDOW/2, 75);
        CGRect restartBound = [restartLabel boundingBox];
        if(CGRectContainsPoint(restartBound, pos))
        {
            [self restart];
            oneWinLabel.position = ccp(-9001, -9001);
        }
        
        [self addChild: oneWinLabel z:3];
    }
    if(two.health <= 0 && !oneWon)
    {
        two.health = 0;
        twoWinLabel = [CCLabelTTF labelWithString:@"Player One Wins!!!" dimensions:CGSizeMake(180,30) alignment:kCCTextAlignmentLeft fontName:@"Marker Felt" fontSize:20];
        twoWinLabel.position = ccp(WIDTH_WINDOW/2, HEIGHT_WINDOW/2);
        twoWinLabel.color = ccBLACK;
        
        restartLabel.position = ccp(WIDTH_WINDOW/2, 75);
        CGRect restartBound = [restartLabel boundingBox];
        if(CGRectContainsPoint(restartBound, pos))
        {
            [self restart];
            twoWinLabel.position = ccp(-9001,-9001);
        }
        
        [self addChild: twoWinLabel z:3];
    }
}
//ONE ATTACK DOES DAMAGE
-(void) doDamage:(EnvironmentalObject*) object toPlayer: (Wizard*) poorSoul byAttacker: (Wizard*) attacker
{
    bool superEffective = false;
    bool notEffective = false;
    int originalDamage = object.damage;
    if(object.emblazed && poorSoul.electric)
    {
        superEffective = true;
        notEffective = false;
    }
    else if(object.electrified && poorSoul.ice)
    {
        superEffective = true;
        notEffective = false;
    }
    else if(object.frozen && poorSoul.flame)
    {
        superEffective = true;
        notEffective = false;
    }
    else if(object.emblazed && poorSoul.ice)
    {
        superEffective = false;
        notEffective = true;
    }
    else if(object.electrified && poorSoul.flame)
    {
        superEffective = false;
        notEffective = true;
    }
    else if(object.frozen && poorSoul.electric)
    {
        superEffective = false;
        notEffective = true;
    }
    if(superEffective)
    {
        if(object.emblazed)
        {
            if(object.type ==0)
            {
                object.damage = object.damage *  (100/ poorSoul.fireResistance);
                poorSoul.electricResistance = poorSoul.electricResistance - 20;
            }
            else if(object.type == 1)
            {
                object.damage = object.damage * (100/ poorSoul.fireResistance);
                attacker.fireResistance = attacker.fireResistance + 10;
            }
            else if(object.type == 2)
            {
                object.damage = object.damage * (100/ poorSoul.fireResistance);
                attacker.iceResistance = attacker.iceResistance - 15;
            }
        }
        else if(object.frozen)
        {
            if(object.type ==0)
            {
                object.damage = object.damage * (100/ poorSoul.iceResistance);
                poorSoul.fireResistance = poorSoul.fireResistance - 20;
            }
            else if(object.type == 1)
            {
                object.damage = object.damage * (100/ poorSoul.iceResistance);
                attacker.iceResistance = attacker.fireResistance + 10;
            }
            else if(object.type == 2)
            {
                object.damage = object.damage * (100/ poorSoul.iceResistance);
                attacker.electricResistance = attacker.electricResistance - 15;
            }
        }
        else if(object.electrified)
        {
            if(object.type ==0)
            {
                object.damage = object.damage *  (100/ poorSoul.electricResistance);
                poorSoul.iceResistance = poorSoul.iceResistance - 20;
            }
            else if(object.type == 1)
            {
                object.damage = object.damage * (100/ poorSoul.electricResistance);
                attacker.electricResistance = attacker.fireResistance + 10;
            }
            else if(object.type == 2)
            {
                object.damage = object.damage * (100/ poorSoul.electricResistance);
                attacker.fireResistance = attacker.fireResistance - 15;
            }
        }
    }
    else if(notEffective)
    {
        
    }
    if(!attackTied)
    {
        if(object.emblazed)
        {
            [attacker flameElement];
        }
        else if(object.frozen)
        {
            [attacker iceElement];
        }
        else if(object.electrified)
        {
            [attacker electricElement];
        }
    }
    //UPDATES STATS EVERY ROUND
    healthUpdated = true;
    NSLog(@"Health removed");
    [self removeChild: oneHealthLabel];
    [self removeChild: twoHealthLabel];
    resistanceUpdated = true;
    [self removeChild:oneFireResistance];
    [self removeChild:oneIceResistance];
    [self removeChild:oneElectricResistance];
    [self removeChild:twoFireResistance];
    [self removeChild:twoIceResistance];
    [self removeChild:twoElectricResistance];
    
    NSLog([NSString stringWithFormat:@"%d", object.damage]);
    NSString* testElement;
    if(attacker.flame)
    {
        testElement = @"Flame";
    }
    else if(attacker.ice)
    {
        testElement = @"ice";
    }
    else if(attacker.electric)
    {
        testElement = @"electric";
    }
    NSLog(testElement);
    poorSoul.health = poorSoul.health - object.damage;
    object.damage = originalDamage;
    [self wizardAttribute:attacker];
    attackTied = false;
}
//TRANSITIONS FROM PLAYER ONE TO PLAYER TWO AND VICE VERSA
-(void) nextTurn
{
    bigChosenImage.position = ccp(-9001, -9001);
    mediumChosenImage.position = ccp(-9001, -9001);
    smallChosenImage.position = ccp(-9001, -9001);
    attackCounter = 0;
    for(int i = 0; i < AMOUNT_OF_OBJECTS; i++)
    {
        CCSprite* tempChosen = [haveChosen objectAtIndex:i];
        tempChosen.visible = false;
    }
    if(onesturn)
    {
        oneChosen = true;
        onesturn = false;
    }
    else
    {
        twoChosen = true;
        onesturn = true;
    }
    if(!turnUpdated)
    {
        turnUpdated = true;
        NSLog(@"turn updated");
        [self removeChild: turnLabel];
        //turnUpdated = false;
    }
    if(!countUpdated)
    {
    countUpdated = true;
    [self removeChild:countLabel];
    }
    objectSelected = false;
}
//RESTARTS THE GAME
-(void) restart
{
    bigChosenImage.position = ccp(-9001, -9001);
    mediumChosenImage.position = ccp(-9001, -9001);
    smallChosenImage.position = ccp(-9001, -9001);
    restartLabel.position = ccp(-9001, -9001);

    oneMax = 4;
    twoMax = 4;
    countUpdated = true;
    healthUpdated = true;
    resistanceUpdated = true;
    [self removeChild:oneWinLabel];
    [self removeChild:twoWinLabel];
    [self removeChild:countLabel];
    [self removeChild:fireLabel];
    [self removeChild:iceLabel];
    [self removeChild: electricLabel];
    [self removeChild: oneHealthLabel];
    [self removeChild: twoHealthLabel];
    [self removeChild:oneFireResistance];
    [self removeChild:oneIceResistance];
    [self removeChild:oneElectricResistance];
    [self removeChild:twoFireResistance];
    [self removeChild:twoIceResistance];
    [self removeChild:twoElectricResistance];
    one.health = 100;
    two.health = 100;
    oneFireElement.visible = false;
    twoFireElement.visible = false;
    oneIceElement.visible = false;
    twoIceElement.visible = false;
    oneElectricElement.visible = false;
    twoElectricElement.visible = false;
}
@end
