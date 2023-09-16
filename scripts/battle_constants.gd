extends Node

var rng = RandomNumberGenerator.new()
# Create dictionaries and arrays of dialog for insult, charisma and hat pools. 
## Each dialog option needs a short form and a long form

const hat_sayings = {
	"wizard": {"short": "Magic in the air", "long": "By the ancient arts, I summon a powerful spell."},
	"witch": {"short": "Stirring the cauldron", "long": "With a twist of my wand, I brew a potent potion."},
	"snapback": {"short": "Too cool for school", "long": "Check out my style, can't match this cool vibe."},
	"shroom": {"short": "Feeling fungi-fine", "long": "By the power of the fungi, I grow in strength."},
	"nurse": {"short": "Doctor's day off", "long": "With care and compassion, I mend our wounds."},
	"hardhat": {"short": "Hardly a scratch", "long": "This helmet shields me from harm."},
	"fedora": {"short": "M'lady's favorite", "long": "With a tip of my hat, I exude charm and grace."},
	"crown": {"short": "King for a day", "long": "By the right of royalty, I command power."},
	"cowboy": {"short": "Howdy, partner", "long": "With a quick hand, I'm ready for action."},
	"baseball": {"short": "Curveball incoming", "long": "Step up to the plate, it's time to hit a home run."},
	"cloche": {"short": "Roaring in style", "long": "With elegance and poise, I'm ready for any challenge."},
	"floppy": {"short": "Beach day every day", "long": "Taking it easy, nothing can faze me now."},
	"pirate": {"short": "Seeking buried gold", "long": "Yarrr! By the seven seas, I'm unstoppable."},
	"straw": {"short": "Picnic-ready look", "long": "With this straw hat, the sun won't bother me."},
	"beanie": {"short": "Cozy head, warm heart", "long": "Feeling cozy and ready to take on the cold."},
	"fairy": {"short": "Light on my wings", "long": "With a sprinkle of fairy dust, I soar through the skies."},
	"monster": {"short": "Cute, but fierce", "long": "Fear me, for I have the strength of a beast."},
	"sport": {"short": "Game face on", "long": "With determination, I'm going for the gold."},
	"tophat": {"short": "Tea time elegance", "long": "With sophistication, nothing stands in my way."},
	"raccoon": {"short": "Sneaky snack time", "long": "Quick and sneaky, I take what I desire."},
	"party": {"short": "Dance floor king", "long": "It's time to party and spread joy everywhere."}
}

func captivate(cha):
	return { "def": cha }

func overwhelm(cha):
	return {"wit": cha}
	
func inspire(cha):
	return  {'wit': ceil(cha / 2), 'cha': ceil(cha / 2)}
	
func intimidate(cha):
	return {"def": -1, "wit": cha}

func fortify(cha):
	return {"def": cha + 2, "wit": -2}
	
	
## NEEDS BALANCE THESE ARE JUST FOR IDEAS AND FORMATTING
var CHA_POWERS = {
	"CAPTIVATE": captivate,
	"INSPIRE": inspire,
	"INTIMIDATE": intimidate,
	"FORTIFY": fortify,
	"OVERWHELM": overwhelm
}

const HAT_CHA_POWERS = {
	"wizard": "INSPIRE",        # Wizards are known for their inspiration and wisdom
	"witch": "CAPTIVATE",       # Witches often captivate with their mystique
	"snapback": "INTIMIDATE",   # Modern snapbacks can be seen as a sign of assertiveness, hence intimidate
	"shroom": "OVERWHELM",      # Psychedelic and overwhelming in nature
	"nurse": "FORTIFY",         # Nurses help fortify health and well-being
	"hardhat": "INSPIRE",       # Hard work and perseverance, hence inspire
	"fedora": "CAPTIVATE",      # Fedora often represents a captivating figure
	"crown": "OVERWHELM",       # Kings and queens possess an overwhelming presence
	"cowboy": "INTIMIDATE",     # The wild west cowboy intimidation
	"baseball": "INSPIRE",      # Baseball caps represent team spirit, hence inspire
	"cloche": "CAPTIVATE",      # Vintage charm, hence captivating
	"floppy": "FORTIFY",        # Floppy hats offer protection from the sun, hence fortify
	"pirate": "INTIMIDATE",     # Pirates are known for their intimidating presence
	"straw": "INSPIRE",         # Straw hats are simple and grounding
	"beanie": "FORTIFY",        # Beanies fortify against cold weather
	"fairy": "CAPTIVATE",       # Magical and captivating
	"monster": "OVERWHELM",     # Monstrous presence can be overwhelming
	"sport": "INSPIRE",         # Sports caps represent team spirit, hence inspire
	"tophat": "CAPTIVATE",      # Classic high-class hat, captivating in nature
	"raccoon": "INTIMIDATE",    # Sneaky raccoons can be intimidating
	"party": "CAPTIVATE"        # It's a party! Captivate everyone!
}

func damage_formula(user_wit, opp_def, damange_range):
	return clamp(user_wit + damange_range - opp_def, 1, INF)

func no_damage(_user_wit, _opp_def):
	return 0

func witch(user_wit, opp_def):
	rng.randomize()
	return damage_formula(user_wit, opp_def, rng.randi_range(3, 5))

func cowboy(cha):
	return {"wit": 2 + cha}
	
var HAT_ABILITIES = {
	# EITHER DMG OR CHA NOT BOTH
	"witch": {'dmg': witch},
	"cowboy": {'cha': cowboy},
	
	# ... [Continue in this format for the rest of the hats]
}


var CHA_DIALOG_OPTIONS = {
	"CAPTIVATE": [
		{
			"short": "Entranced by me?",
			"long": "Are you finding yourself mysteriously drawn into my charm and allure?"
		},
		{
			"short": "Lost in my gaze?",
			"long": "My eyes have a unique power, don't they? Feeling lost in their depth?"
		},
		{
			"short": "Feeling spellbound?",
			"long": "I can see the fascination in your eyes. Are you feeling entirely spellbound?"
		}
	],
	"INSPIRE": [
		{
			"short": "Aim for greatness.",
			"long": "Always remember to aim for greatness, no matter the obstacles."
		},
		{
			"short": "Rise above it.",
			"long": "Regardless of the hardships, always rise above and inspire others."
		},
		{
			"short": "Shine on.",
			"long": "Continue shining your light and inspire those around you."
		}
	],
	"INTIMIDATE": [
		{
			"short": "Want to back off?",
			"long": "Perhaps it's in your best interest to reconsider your stance, don't you think?"
		},
		{
			"short": "Second thoughts?",
			"long": "I wouldn't want to be in your shoes right now. Having second thoughts?"
		},
		{
			"short": "Scared yet?",
			"long": "You might not want to push me any further. Feeling the pressure yet?"
		}
	],
	"FORTIFY": [
		{
			"short": "Strengthen your core.",
			"long": "Focus on your inner strength. Bolster your defenses and remain unyielding."
		},
		{
			"short": "Build your walls.",
			"long": "It's time to build those walls up. Fortify your position and stand firm."
		},
		{
			"short": "Stay rooted.",
			"long": "Like a mighty oak tree, stay rooted and unwavering in the face of adversity."
		}
	],
	"OVERWHELM": [
		{
			"short": "Feeling swamped?",
			"long": "Do you feel like you're drowning in my presence, unable to find your footing?"
		},
		{
			"short": "Too much to handle?",
			"long": "My aura is intense. Do you find it too overwhelming?"
		},
		{
			"short": "Lost in the storm?",
			"long": "Like a tempest, I can be quite overpowering. Can you weather my storm?"
		}
	]
}



const WIT_INSULTS = [
	{
		"short": "Brain fade moment",
		"long": "Did your brain take a little vacation?"
	},
	{
		"short": "A genius... in reverse",
		"long": "If brains were dynamite, you wouldn't have enough to blow your nose."
	},
	{
		"short": "The light's off, clearly",
		"long": "The light's on but nobody's home, huh?"
	},
	{
		"short": "A gifted talker, indeed",
		"long": "Ever thought of competing in a talking marathon? You'd win!"
	},
	{
		"short": "Einstein's polar opposite",
		"long": "Somewhere out there, Einstein's regretting that theory of relativity."
	},
	{
		"short": "Shiny but empty up there",
		"long": "You have such a clear mind; it's like a polished crystal ball."
	},
	{
		"short": "Such a brainy little bird",
		"long": "You'd lose in a battle of wits against a pigeon."
	},
	{
		"short": "Think train's gone off-track",
		"long": "Your thought train derailed quite a while back, didn't it?"
	},
	{
		"short": "A star, just not so bright",
		"long": "You're a star... just not the brightest in the sky."
	},
	{
		"short": "Definitely not the sharpest",
		"long": "You might not be the sharpest tool, but you're definitely a tool."
	},
	{
		"short": "Mind the vast gap there",
		"long": "Your mind has more gaps than the London Underground."
	},
	{
		"short": "A true witless wonder",
		"long": "Were you born this witty or did you take lessons?"
	},
	{
		"short": "Just one brick short, huh?",
		"long": "You're just one brick short of a full load, aren't you?"
	},
	{
		"short": "That dim spotlight in the mind",
		"long": "In the theater of your mind, I think the spotlight's a bit dim."
	},
	{
		"short": "A misfiring cog, perhaps?",
		"long": "There's a cog loose in that brain of yours, isn't there?"
	},
	{
		"short": "Running on low battery, are we?",
		"long": "Is your brain running on low battery today?"
	},
	{
		"short": "Such an intellectual void",
		"long": "Your mind is like a black hole where intellect disappears."
	},
	{
		"short": "Reached the wit's end already?",
		"long": "Looks like you've reached your wit's end."
	},
	{
		"short": "Rocking that grade Z brain",
		"long": "If brains had grades, yours might just squeeze into the Z category."
	},
	{
		"short": "All I hear is crickets chirping",
		"long": "Is that the sound of crickets I hear every time you think?"
	},
	{
		"short": "Big snooze alert right here",
		"long": "Whenever you speak, I hear my bed calling me."
	},
	{
		"short": "Thoughts on a glacier pace",
		"long": "Your thoughts move at glacial speed, don't they?"
	},
	{
		"short": "Oh, where did that wit go?",
		"long": "Did your wit just vanish in a puff of its own insignificance?"
	},
	{
		"short": "Such a pristine blank slate",
		"long": "Your brain is such a pristine blank slate. Clean as a whistle!"
	},
	{
		"short": "Elevator's stuck midway, huh?",
		"long": "Your intellectual elevator doesn't quite reach the top floor, huh?"
	},
	{
		"short": "Venturing the mystery zone",
		"long": "The Bermuda Triangle has nothing on the mystery of your thoughts."
	},
	{
		"short": "Alert for the dense fog ahead",
		"long": "Your mind's under a perpetual dense fog advisory."
	},
	{
		"short": "In the vast echo chamber",
		"long": "Is there an echo in here or is that just your brain processing?"
	},
	{
		"short": "Such a deep, empty void",
		"long": "You've a depth to your intellect. It's a bottomless void."
	},
	{
		"short": "Cotton candy brain in action",
		"long": "Your brain must be made of cotton candy, fluffy and without substance."
	},
	{
		"short": "The light year response delay",
		"long": "Your response time is like a light year. I might grow old waiting."
	},
	{
		"short": "Noisy muted trumpet vibes",
		"long": "Your thoughts sound like a muted trumpet, mostly noise."
	},
{
		"short": "Floating down a lazy river",
		"long": "Your intellect reminds me of a lazy river, slow and aimless."
	},
	{
		"short": "Staring into a witless void",
		"long": "I've seen voids with more wit than you!"
	},
	{
		"short": "Moving at a snail's pace",
		"long": "If thoughts were races, yours would be led by snails."
	},
	{
		"short": "Chasing a desert mirage",
		"long": "Your ideas are like mirages in a desert, non-existent up close."
	},
	{
		"short": "Relying on a lost compass",
		"long": "Your thoughts are like a broken compass, going in every direction but the right one."
	},
	{
		"short": "Choosing a dull crayon",
		"long": "In the crayon box of life, you're the dull gray one."
	},
	{
		"short": "Buzzing like a befuddled bee",
		"long": "Your mind buzzes like a bee, but without direction."
	},
	{
		"short": "Chasing the tail of circular logic",
		"long": "Your logic is so circular, it's like chasing your own tail."
	},
	{
		"short": "Pairing mismatched socks",
		"long": "You're like mismatched socks. Unique, but a tad confusing."
	},
	{
		"short": "Navigating with a lost map",
		"long": "It seems your life's GPS lost the map. Recalculating..."
	},
	{
		"short": "Wearing all hat, but having no cattle",
		"long": "You remind me of the saying, 'All hat and no cattle.'"
	},
	{
		"short": "Ticking like a backwards clock",
		"long": "You're like a clock that runs backwards. Interesting but not very useful."
	},
	{
		"short": "Walking with untied shoes",
		"long": "Your efforts remind me of untied shoelaces. A trip waiting to happen."
	},
	{
		"short": "Setting off a damp squib",
		"long": "That effort was a bit of a damp squib, wasn't it?"
	},
	{
		"short": "Floating like a lost kite",
		"long": "You're like a kite with no string. Free but directionless."
	},
	{
		"short": "Wandering with zipped pockets",
		"long": "Ever feel like you're all zipped up with nowhere to go?"
	},
	{
		"short": "Pedaling a rusty bike",
		"long": "Using that strategy is like riding a rusty bike. Squeaky and slow."
	},
	{
		"short": "Peering into a cloudy mirror",
		"long": "You're like a cloudy mirror. I can see the outline but the details are hazy."
	},
	{
		"short": "Drifting like a leaf in the wind",
		"long": "Your plans sway more than a leaf in a gusty wind."
	},
	{
		"short": "Untangling a messy yarn",
		"long": "The way you go about things is like tangled yarn. Where's the start, where's the end?"
	},
	{
		"short": "Glowing as a deceptive full moon",
		"long": "You shine bright like a full moon, but cause a few lunatics along the way."
	},
	{
		"short": "Searching like it's for a lost remote",
		"long": "Your approach is like searching for a lost remote. Haphazardly flipping cushions."
	},
	{
		"short": "Following a skewed compass",
		"long": "Your moral compass seems a bit skewed. Maybe it's drawn to fun mischief?"
	},
	{
		"short": "Twinkling like a faded star",
		"long": "You're not the brightest star in the sky, but you sure have your moments."
	},
	{
		"short": "Fumbling with an untuned radio",
		"long": "Listening to you is like an untuned radio. A mix of clarity and static."
	},
	{
		"short": "Placing that odd jigsaw piece",
		"long": "You're like that one jigsaw piece that doesn't fit. Oddly intriguing."
	},
	{
		"short": "Grasping for slippery soap",
		"long": "Trying to understand you is like catching a slippery soap. Almost got it!"
	},
	{
		"short": "Tasting the crunch of burnt toast",
		"long": "Your efforts sometimes remind me of burnt toast. Crunchy but not quite right."
	},
	{
		"short": "Mismatched shoes in a party",
		"long": "If style was a crime, you'd be serving a life sentence."
	},
	{
		"short": "Lost in a round room",
		"long": "Ever get the feeling of being lost in a round room? No corners to hide in!"
	},
	{
		"short": "Tornado in a junkyard",
		"long": "Your strategy reminds me of a tornado in a junkyard. Chaotic and full of scraps."
	},
	{
		"short": "Penguin in a desert",
		"long": "You're as out of place as a penguin in a desert. Cute, but bewildered."
	},
	{
		"short": "Solar flashlight at night",
		"long": "Your actions are like using a solar flashlight at night. Interesting, but not illuminating."
	},
	{
		"short": "Camouflage in a neon room",
		"long": "Your subtlety is like wearing camouflage in a neon room. Bright and out of place."
	},
	{
		"short": "Goldfish on a mountaintop",
		"long": "You look as confused as a goldfish on a mountaintop. Just keep swimming?"
	},
	{
		"short": "Sunglasses in a cave",
		"long": "Wearing those shades indoors? You're like someone with sunglasses in a cave."
	},
	{
		"short": "Sandals in the snow",
		"long": "Your readiness reminds me of someone wearing sandals in a snowstorm. Chilled toes, anyone?"
	},
	{
		"short": "Lighthouse in a bathtub",
		"long": "Your attempts at guidance are like a lighthouse in a bathtub. Bright but pointless."
	},
	{
		"short": "Dancing porcupine in a balloon store",
		"long": "Your moves are as unpredictable as a dancing porcupine in a balloon store. Prickly and unexpected!"
	},
	{
		"short": "Book in a swimming pool",
		"long": "Your depth of knowledge is like a book in a swimming pool. Soggy but still readable."
	},
	{
		"short": "Whale in a puddle",
		"long": "Seeing you here is like spotting a whale in a puddle. Surprising and a bit cramped."
	},
	{
		"short": "Kettle in a library",
		"long": "Your approach is as noisy and out of place as a kettle in a library."
	},
	{
		"short": "Skis on a beach holiday",
		"long": "You're as prepared as someone bringing skis to a beach holiday. Ready to slide on sand?"
	},
	{
		"short": "Cactus at a water park",
		"long": "You stand out like a cactus at a water park. Pointy and slightly intimidating."
	},
	{
		"short": "Snowman in a sauna",
		"long": "You melt under pressure like a snowman in a sauna. Steamy and short-lived."
	},
	{
		"short": "Rooster at a midnight party",
		"long": "You're the rooster at a midnight party. Eager but with odd timing."
	},
	{
		"short": "Fish climbing a tree",
		"long": "Your ambition is like a fish trying to climb a tree. Admirable but misplaced."
	},
	{
		"short": "Sloth in a sprint race",
		"long": "Your pace is like a sloth in a sprint race. Taking it slow and steady."
	},
	{
		"short": "That hat's a fashion mishap",
		"long": "Did your hat come with a time machine? It's screaming last century."
	},
	{
		"short": "Hat's off, or better, on?",
		"long": "Is that hat a secret weapon? It's definitely doing... something."
	},
	{
		"short": "Top of your head's best covered",
		"long": "I've always said, if you can't be smart, at least be decorative. Your hat proves it."
	},
	{
		"short": "Hat or satellite dish?",
		"long": "Is that hat picking up good reception? It's certainly not picking up style points."
	},
	{
		"short": "Headwear or bird's nest?",
		"long": "I've heard of being one with nature, but your hat takes it to the next level."
	},
	{
		"short": "Mystery beneath that lid?",
		"long": "With a hat like that, you must be hiding some incredible ideas... or maybe just a bad hair day?"
	},
	{
		"short": "A hat of many mysteries",
		"long": "I have to ask – does that hat come with a user manual? It's quite the... statement."
	},
	{
		"short": "Brave choice of headgear",
		"long": "That hat is... bold. I wouldn't have the courage."
	},
	{
		"short": "Fashion-forward or fashion-folly?",
		"long": "Your hat is so unique, I've never seen anything quite like it. And I'm not sure I wanted to."
	},
	{
		"short": "Hat trendsetter or setter of bad trends?",
		"long": "Hats off to you for trying something new. I just wish it was something good."
	},
	{
		"short": "Daring hat decision",
		"long": "In a world of common hats, yours certainly... stands out."
	},
	{
		"short": "A hat of questionable intent",
		"long": "Does your hat have a purpose or is its only mission to confuse?"
	},
	{
		"short": "Confounding cap choice",
		"long": "I always say, wear what you love. But with that hat, are you sure?"
	},
	{
		"short": "Statement or scream?",
		"long": "Your hat makes a statement. I'm just not sure if it's a fashion one or a cry for help."
	},
	{
		"short": "Head-turner for right reasons?",
		"long": "Your hat certainly turns heads. Mostly in the other direction."
	},
	{
		"short": "Lid logic lacking",
		"long": "I'm trying to understand the logic behind that hat choice. Still trying..."
	},
	{
		"short": "Headwear or hazard?",
		"long": "Is that hat for style or safety? It's hard to tell."
	},
	{
		"short": "Hat's curious, to say the least",
		"long": "I always wondered what became of my grandma's old lampshade."
	},
	{
		"short": "That's a... unique choice",
		"long": "I've always believed in personal expression, but that hat's really pushing it."
	},
	{
		"short": "Style experiment gone wrong?",
		"long": "I appreciate experimental fashion, but is your hat the result or the cause?"
	},
	{
		"short": "Bold hat move there",
		"long": "With a hat like that, you're either ahead of your time or... lost in it."
	},
	{
		"short": "Is that hat in beta?",
		"long": "I feel like your hat is still in its testing phase. Right?"
	},
	{
		"short": "Interesting lid logic",
		"long": "I respect the courage to wear that hat. Understanding it? That's another story."
	},
	{
		"short": "A hat that raises brows",
		"long": "Every time I look at your hat, my eyebrows raise a little more."
	},
	{
		"short": "That hat's a riddle",
		"long": "I'm trying to figure out the story behind that hat. Still thinking..."
	},
	{
		"short": "Distracting by design?",
		"long": "Is that hat meant to distract from the game or from a bad hair day?"
	},
	{
		"short": "Captivating cap choice",
		"long": "Your hat is truly captivating. I can't look away, no matter how much I want to."
	},
	{
		"short": "Fashion or faux pas?",
		"long": "I must commend you. Not everyone can rock a hat like... well, whatever that is."
	},
	{
		"short": "Hat innovation or illusion?",
		"long": "I'm not sure if that hat is avant-garde or just avant-garbage."
	},
	{
		"short": "Headpiece or puzzle piece?",
		"long": "That hat feels like a piece from a different puzzle. Not this game, surely."
	},
	{
		"short": "Eyes on the hat prize",
		"long": "It's clear you're going for a prize with that hat. Just not sure which one."
	},
	{
		"short": "Lid choices speak loudly",
		"long": "They say hats make a statement. Yours is shouting... something."
	}, 
	{
		"short": "Hat misjudgment",
		"long": "Did your hat come with a free lesson on poor choices?"
	},
	{
		"short": "Hat's tragic tale",
		"long": "Your hat tells a story, and it's a tragedy."
	},
	{
		"short": "Hat's reflection",
		"long": "Your hat is the perfect reflection of your taste – questionable at best."
	},
	{
		"short": "Hat's revelation",
		"long": "Every time you wear that hat, it reveals more about your lack of fashion sense than you might realize."
	},
	{
		"short": "Hat's cry for help",
		"long": "Is your hat a fashion statement or a cry for help?"
	},
	{
		"short": "Hat's wasted potential",
		"long": "There's a universe where that hat looked good. This isn't it."
	},
	{
		"short": "Hat's misplaced confidence",
		"long": "The confidence you have while wearing that hat... commendable, yet misplaced."
	},
	{
		"short": "Hat's silent scream",
		"long": "If hats could scream, yours would be asking for a better head."
	},
	{
		"short": "Hat's identity crisis",
		"long": "Your hat seems to be having an identity crisis, just like its owner."
	},
	{
		"short": "Hat's lost purpose",
		"long": "I believe every hat has a purpose, but yours is still searching."
	},
	{
		"short": "Hat's mistaken pride",
		"long": "The pride you feel in that hat must be a mistake, right?"
	},
	{
		"short": "Hat's false allure",
		"long": "If you think that hat adds to your allure, think again."
	},
	{
		"short": "Hat's misguided journey",
		"long": "Of all the hats in the world, you chose that one. It's a journey of misguided decisions."
	},
	{
		"short": "Hat's loud mediocrity",
		"long": "Your hat doesn't whisper mediocrity, it screams it."
	},
	{
		"short": "Hat's fashion faux pas",
		"long": "In the book of fashion faux pas, your hat deserves its own chapter."
	},
	{
		"short": "Topper travesty",
		"long": "Your sense of style went south the moment you put that topper on."
	},
	{
		"short": "Cap's curious choice",
		"long": "Of all the caps in the world, you went with that one?"
	},
	{
		"short": "Headgear horror show",
		"long": "Your headgear could give nightmares to a fashionista."
	},
	{
		"short": "Lid's laughable legacy",
		"long": "That lid is a legacy, a testament to your laughable fashion sense."
	},
	{
		"short": "Headdress's hilarious hint",
		"long": "Your headdress hints at a sense of humor, because surely you're joking with that choice."
	},
	{
		"short": "Beret blunder brilliance",
		"long": "Every time I see that beret, I marvel at your unmatched talent for blunders."
	},
	{
		"short": "Crown's comedic catastrophe",
		"long": "If you're aiming for comedic relief with that crown, well done!"
	},
	{
		"short": "Beanie's baffling blip",
		"long": "That beanie is a blip on the radar of bad fashion choices."
	},
	{
		"short": "Fedora's fashion flop",
		"long": "Your fedora looks like it's borrowed from a museum of fashion missteps."
	},
	{
		"short": "Bandana's bewildering bet",
		"long": "Wearing that bandana is a bet against good taste, and I'm afraid you're losing."
	},
	{
		"short": "Helmet's hilarious hiccup",
		"long": "The only defense that helmet offers is against compliments."
	},
	{
		"short": "Turbulent turban tales",
		"long": "Your turban tells tales of turbulent fashion decisions."
	},
	{
		"short": "Panama's puzzling parade",
		"long": "That Panama hat parades puzzling decisions, one after the other."
	},
	{
		"short": "Bonnet's baffling boast",
		"long": "Your bonnet boasts of baffling choices and glaring regrets."
	},
	{
		"short": "Sombrero's sassy statement",
		"long": "Your sombrero makes such a sassy statement. Too bad it's all sass and no class."
	},
	{
		"short": "Cap's comical claim",
		"long": "Of every cap I've seen, yours makes the most comical claim to fashion."
	},
	{
		"short": "Hood's humorous havoc",
		"long": "The havoc your hood wreaks on style is humorously horrifying."
	},
	{
		"short": "Top hat's tragic tale",
		"long": "That top hat tells a tragic tale of trends gone terribly wrong."
	},
	{
		"short": "Cowboy's curious calamity",
		"long": "Your cowboy hat is a calamity of curious choices."
	},
	{
		"short": "Trilby's troublesome tribute",
		"long": "Wearing that trilby is like paying tribute to troublesome taste."
	},
	{
		"short": "Bucket's baffling badge",
		"long": "Your bucket hat serves as a baffling badge of dubious distinction."
	},
	{
		"short": "Snapback's silly saga",
		"long": "The saga of your snapback is both silly and slightly sad."
	},
	{
		"short": "Fez's funny fable",
		"long": "Your fez spins a funny fable of fashion faux pas."
	},
	{
		"short": "Derby's dubious dance",
		"long": "The dance of your derby hat dips into the domain of the dubious."
	},
	{
		"short": "Tam's tantalizing tangle",
		"long": "That tam of yours tangles tantalizingly with tragic taste."
	},
	{
		"short": "Boater's bold blip",
		"long": "Your boater hat is but a bold blip on the bad fashion radar."
	},
	{
		"short": "Cloche's comedic chronicle",
		"long": "The chronicle of your cloche is a comedic cascade of confusion."
	},
	{
		"short": "Visor's vexing voyage",
		"long": "The voyage of that visor ventures into very vexing valleys of vogue."
	}
]
