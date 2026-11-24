import json
from pathlib import Path

def mk(i, en, my, ph, em, ex_en, ex_my, color=None):
    d = {
        "id": i, "english": en, "myanmar": my, "phonetic": ph, "emoji": em,
        "audioKey": i, "exampleEn": ex_en, "exampleMy": ex_my, "exampleAudioKey": f"{i}_ex"
    }
    if color is not None:
        d["colorHex"] = color
    return d

def mod(mid, order, ten, tmy, den, dmy, icon, col, cat, rows):
    items = []
    for idx, r in enumerate(rows, 1):
        c = r[6] if len(r) > 6 else None
        items.append(mk(f"{mid}_{idx}", r[0], r[1], r[2], r[3], r[4], r[5], c))
    return {
        "id": mid, "grade": 1, "order": order, "titleEn": ten, "titleMy": tmy,
        "descriptionEn": den, "descriptionMy": dmy, "icon": icon,
        "colorHex": col, "category": cat, "items": items
    }

extra = [
    mod("g1_colors", 4, "Colors", "အရောင်များ", "Bright colors around us.", "ပတ်ဝန်းကျင်က အရောင်လှလှလေးများ။", "🎨", 0xFFFF7AA2, "colors", [
        ("Red","အနီရောင်","/rɛd/","❤️","The rose is red.","နှင်းဆီပန်းက အနီရောင်ပါ။",0xFFE53935),
        ("Blue","အပြာရောင်","/bluː/","💙","The sky is blue.","ကောင်းကင်ကြီးက အပြာရောင်ပါ။",0xFF1E88E5),
        ("Yellow","အဝါရောင်","/ˈjɛl.oʊ/","💛","The banana is yellow.","ငှက်ပျောသီးက အဝါရောင်ပါ။",0xFFFDD835),
        ("Green","အစိမ်းရောင်","/ɡriːn/","💚","Grass is green.","မြက်ခင်းက အစိမ်းရောင်ပါ။",0xFF43A047),
        ("Orange","လိမ္မော်ရောင်","/ˈɒr.ɪndʒ/","🧡","My ball is orange.","ငါ့ဘောလုံးက လိမ္မော်ရောင်ပါ။",0xFFFB8C00),
        ("Purple","ခရမ်းရောင်","/ˈpɜːr.pəl/","💜","Grapes are purple.","စပျစ်သီးတွေက ခရမ်းရောင်ပါ။",0xFF8E24AA),
        ("Pink","ပန်းရောင်","/pɪŋk/","🩷","She wears a pink bow.","သူမ ပန်းရောင်ဖဲပြားလေး ပန်ထားတယ်။",0xFFEC407A),
        ("White","အဖြူရောင်","/waɪt/","🤍","Clouds are white.","တိမ်တွေက အဖြူရောင်ပါ။",0xFFB0BEC5),
        ("Black","အနက်ရောင်","/blæk/","🖤","My shoes are black.","ငါ့ဖိနပ်က အနက်ရောင်ပါ။",0xFF37474F),
        ("Brown","အညိုရောင်","/braʊn/","🤎","The puppy is brown.","ခွေးပေါက်လေးက အညိုရောင်ပါ။",0xFF6D4C41),
    ]),
    mod("g1_animals", 5, "Animals", "တိရစ္ဆာန်များ", "Meet cute friendly animals.", "ချစ်စရာ တိရစ္ဆာန်လေးများနှင့် မိတ်ဆက်မယ်။", "🐾", 0xFF38C98F, "animals", [
        ("Cat","ကြောင်","/kæt/","🐱","The cat drinks milk.","ကြောင်လေး နို့သောက်နေတယ်။"),
        ("Dog","ခွေး","/dɒɡ/","🐶","The dog wags its tail.","ခွေးလေး အမြီးနှံ့နေတယ်။"),
        ("Bird","ငှက်","/bɜːrd/","🐦","A little bird sings.","ငှက်ကလေး သီချင်းဆိုနေတယ်။"),
        ("Fish","ငါး","/fɪʃ/","🐟","Fish live in water.","ငါးတွေ ရေထဲမှာ နေကြတယ်။"),
        ("Rabbit","ယုန်","/ˈræb.ɪt/","🐰","The rabbit loves carrots.","ယုန်လေးက မုန်လာဥနီ ကြိုက်တယ်။"),
        ("Elephant","ဆင်","/ˈɛl.ɪ.fənt/","🐘","The elephant has a long trunk.","ဆင်ကြီးမှာ နှာမောင်းရှည်ကြီးရှိတယ်။"),
        ("Lion","ခြင်္သေ့","/ˈlaɪ.ən/","🦁","The lion roars loudly.","ခြင်္သေ့ကြီး အကျယ်ကြီး ဟိန်းတယ်။"),
        ("Monkey","မျောက်","/ˈmʌŋ.ki/","🐵","The monkey climbs trees.","မျောက်လေး သစ်ပင်တက်တယ်။"),
        ("Cow","နွား","/kaʊ/","🐮","The cow gives us milk.","နွားမကြီးက နို့ပေးတယ်။"),
        ("Duck","ဘဲ","/dʌk/","🦆","The yellow duck swims.","ဘဲဝါလေး ရေကူးနေတယ်။"),
    ]),
    mod("g1_fruits", 6, "Fruits", "သစ်သီးများ", "Sweet and healthy fruits.", "ချိုမြိန်ပြီး ကျန်းမာရေးနဲ့ညီညွတ်တဲ့ သစ်သီးများ။", "🍎", 0xFFFF9B6A, "fruits", [
        ("Apple","ပန်းသီး","/ˈæp.əl/","🍎","I eat a crunchy apple.","ငါ ကြွပ်တဲ့ ပန်းသီးစားတယ်။"),
        ("Banana","ငှက်ပျောသီး","/bəˈnɑː.nə/","🍌","Bananas are soft and sweet.","ငှက်ပျောသီးက နူးညံ့ပြီး ချိုတယ်။"),
        ("Mango","သရက်သီး","/ˈmæŋ.ɡoʊ/","🥭","Myanmar mangoes are yummy.","မြန်မာသရက်သီးက အရမ်းအရသာရှိတယ်။"),
        ("Orange","လိမ္မော်သီး","/ˈɒr.ɪndʒ/","🍊","Oranges have sweet juice.","လိမ္မော်သီးမှာ အရည်ချိုချိုလေး ရှိတယ်။"),
        ("Grape","စပျစ်သီး","/ɡreɪp/","🍇","We share a bunch of grapes.","တို့တွေ စပျစ်သီးတစ်ခိုင် မျှစားကြတယ်။"),
        ("Watermelon","ဖရဲသီး","/ˈwɔː.tər.mɛl.ən/","🍉","Watermelon keeps us cool.","ဖရဲသီးက ရင်အေးစေတယ်။"),
        ("Papaya","သင်္ဘောသီး","/pəˈpaɪ.ə/","🍈","Ripe papaya is orange.","သင်္ဘောသီးမှည့်က လိမ္မော်ရောင်ပါ။"),
        ("Strawberry","စတော်ဘယ်ရီ","/ˈstrɔː.bɛr.i/","🍓","A red strawberry on cake.","ကိတ်မုန့်ပေါ်က စတော်ဘယ်ရီသီးနီနီလေး။"),
    ]),
    mod("g1_vegetables", 7, "Vegetables", "ဟင်းသီးဟင်းရွက်များ", "Fresh veggies make you strong.", "လတ်ဆတ်တဲ့ ဟင်းသီးဟင်းရွက်တွေက အားရှိစေတယ်။", "🥕", 0xFF38C98F, "vegetables", [
        ("Carrot","မုန်လာဥနီ","/ˈkær.ət/","🥕","Carrots are good for eyes.","မုန်လာဥနီက မျက်စိအားကောင်းစေတယ်။"),
        ("Tomato","ခရမ်းချဉ်သီး","/təˈmɑː.toʊ/","🍅","Mom buys red tomatoes.","မေမေ ခရမ်းချဉ်သီးနီနီတွေ ဝယ်တယ်။"),
        ("Potato","အာလူး","/pəˈteɪ.toʊ/","🥔","I like mashed potato.","ငါ အာလူးထောင်းကြိုက်တယ်။"),
        ("Onion","ကြက်သွန်နီ","/ˈʌn.jən/","🧅","Onions make soup tasty.","ကြက်သွန်နီက ဟင်းချိုကို အရသာရှိစေတယ်။"),
        ("Corn","ပြောင်းဖူး","/kɔːrn/","🌽","Yellow corn is sweet.","ပြောင်းဖူးဝါလေးက ချိုတယ်။"),
        ("Cabbage","ဂေါ်ဖီထုပ်","/ˈkæb.ɪdʒ/","🥬","Fresh green cabbage.","လတ်ဆတ်တဲ့ ဂေါ်ဖီထုပ်စိမ်းလေး။"),
        ("Cucumber","သခွားသီး","/ˈkjuː.kʌm.bər/","🥒","Cucumber is crisp and fresh.","သခွားသီးက ကြွပ်ပြီး လတ်ဆတ်တယ်။"),
        ("Pumpkin","ရွှေဖရုံသီး","/ˈpʌmp.kɪn/","🎃","A big round pumpkin.","ရွှေဖရုံသီး အဝိုင်းကြီးတစ်လုံး။"),
    ]),
    mod("g1_family", 8, "Family Members", "မိသားစုဝင်များ", "People we love at home.", "အိမ်က ချစ်ရတဲ့ မိသားစုဝင်များ။", "👨‍👩‍👧‍👦", 0xFF9B7BFF, "family", [
        ("Father","အဖေ","/ˈfɑː.ðər/","👨","My father reads to me.","ဖေဖေက ငါ့ကို ပုံပြင်ဖတ်ပြတယ်။"),
        ("Mother","အမေ","/ˈmʌð.ər/","👩","My mother cooks yummy food.","မေမေက အစားအသောက် ကောင်းကောင်းချက်တယ်။"),
        ("Brother","အစ်ကို / မောင်","/ˈbrʌð.ər/","👦","My brother plays football.","ငါ့အစ်ကိုက ဘောလုံးကန်တယ်။"),
        ("Sister","အစ်မ / ညီမ","/ˈsɪs.tər/","👧","My sister likes to draw.","ငါ့အစ်မက ပုံဆွဲရတာ ကြိုက်တယ်။"),
        ("Grandfather","အဘိုး","/ˈɡrænd.fɑː.ðər/","👴","Grandfather tells funny stories.","ဘိုးဘိုးက ရယ်စရာပုံပြင်တွေ ပြောပြတယ်။"),
        ("Grandmother","အဘွား","/ˈɡrænd.mʌð.ər/","👵","Grandmother smiles warmly.","ဘွားဘွားက နွေးနွေးထွေးထွေး ပြုံးပြတယ်။"),
        ("Baby","ကလေးငယ်","/ˈbeɪ.bi/","👶","The baby is sleeping.","ကလေးလေး အိပ်ပျော်နေတယ်။"),
    ]),
    mod("g1_body", 9, "Body Parts", "ခန္ဓာကိုယ်အစိတ်အပိုင်းများ", "Point and name your body parts.", "ခန္ဓာကိုယ်အစိတ်အပိုင်းလေးတွေကို မှတ်သားမယ်။", "🖐️", 0xFF4FB3FF, "body", [
        ("Head","ခေါင်း","/hɛd/","🙂","Nod your head gently.","ခေါင်းလေးကို ညင်ညင်သာသာ ညိတ်ပါ။"),
        ("Eye","မျက်လုံး","/aɪ/","👁️","I see with my eyes.","ငါ မျက်လုံးနဲ့ ကြည့်တယ်။"),
        ("Ear","နားရွက်","/ɪər/","👂","I listen with my ears.","ငါ နားရွက်နဲ့ နားထောင်တယ်။"),
        ("Nose","နှာခေါင်း","/noʊz/","👃","I smell flowers with my nose.","ငါ နှာခေါင်းနဲ့ ပန်းနံ့ရှူတယ်။"),
        ("Mouth","ပါးစပ်","/maʊθ/","👄","Open your mouth and smile.","ပါးစပ်လေးဖွင့်ပြီး ပြုံးလိုက်ပါ။"),
        ("Hand","လက်","/hænd/","✋","Wash your hands before eating.","မစားခင် လက်ဆေးပါ။"),
        ("Foot","ခြေထောက်","/fʊt/","🦶","Put socks on your feet.","ခြေထောက်မှာ ခြေအိတ်စွပ်ပါ။"),
        ("Finger","လက်ချောင်း","/ˈfɪŋ.ɡər/","☝️","I have ten fingers.","ငါ့မှာ လက်ချောင်း ၁၀ ချောင်းရှိတယ်။"),
    ]),
    mod("g1_school", 10, "School Objects", "ကျောင်းသုံးပစ္စည်းများ", "Things inside your classroom.", "စာသင်ခန်းထဲက ကျောင်းသုံးပစ္စည်းများ။", "🎒", 0xFFFFCA3A, "school", [
        ("Book","စာအုပ်","/bʊk/","📖","Open your English book.","မင်းရဲ့ အင်္ဂလိပ်စာအုပ်ကို ဖွင့်ပါ။"),
        ("Pencil","ခဲတံ","/ˈpɛn.səl/","✏️","I write with a pencil.","ငါ ခဲတံနဲ့ စာရေးတယ်။"),
        ("Eraser","ခဲဖျက်","/ɪˈreɪ.zər/","🧽","Use an eraser neatly.","ခဲဖျက်ကို သပ်သပ်ရပ်ရပ် သုံးပါ။"),
        ("Ruler","ပေတံ","/ˈruː.lər/","📏","Draw a line with a ruler.","ပေတံနဲ့ မျဉ်းတားပါ။"),
        ("Bag","လွယ်အိတ်","/bæɡ/","🎒","Pack your school bag.","ကျောင်းလွယ်အိတ်ကို စီထည့်ပါ။"),
        ("Desk","စာရေးခုံ","/dɛsk/","🪑","Keep your desk clean.","စာရေးခုံကို သန့်သန့်ရှင်းရှင်းထားပါ။"),
        ("Chair","ကုလားထိုင်","/tʃɛər/","🪑","Sit nicely on your chair.","ကုလားထိုင်မှာ သပ်သပ်ရပ်ရပ်ထိုင်ပါ။"),
        ("Board","ကျောက်သင်ပုန်း","/bɔːrd/","📋","Look at the classroom board.","ကျောက်သင်ပုန်းကို ကြည့်ပါ။"),
    ]),
    mod("g1_shapes", 11, "Shapes", "ပုံသဏ္ဌာန်များ", "Fun shapes everywhere.", "နေရာတိုင်းမှာတွေ့ရတဲ့ ပုံသဏ္ဌာန်လေးများ။", "🔷", 0xFF9B7BFF, "shapes", [
        ("Circle","စက်ဝိုင်း","/ˈsɜːr.kəl/","⚪","A clock is a circle.","နာရီလေးက စက်ဝိုင်းပုံပါ။"),
        ("Square","စတုရန်း","/skwɛər/","🟦","A square has four equal sides.","စတုရန်းမှာ ညီတူအနား ၄ ဖက်ရှိတယ်။"),
        ("Triangle","တြိဂံ","/ˈtraɪ.æŋ.ɡəl/","🔺","A triangle has three corners.","တြိဂံမှာ ထောင့် ၃ ထောင့်ရှိတယ်။"),
        ("Rectangle","ထောင့်မှန်စတုဂံ","/ˈrɛk.tæŋ.ɡəl/","▬","The door is a rectangle.","တံခါးက ထောင့်မှန်စတုဂံပုံပါ။"),
        ("Star","ကြယ်ပုံ","/stɑːr/","⭐","Draw a golden star.","ရွှေကြယ်ပုံလေး ဆွဲလိုက်ပါ။"),
        ("Heart","အသည်းပုံ","/hɑːrt/","❤️","A heart means love.","အသည်းပုံလေးက ချစ်ခြင်းမေတ္တာပါ။"),
    ]),
    mod("g1_days", 12, "Days of the Week", "တစ်ပတ်တာ နေ့ရက်များ", "Seven happy days in a week.", "တစ်ပတ်မှာရှိတဲ့ ပျော်စရာ ၇ ရက်။", "📅", 0xFF4FB3FF, "days", [
        ("Monday","တနင်္လာနေ့","/ˈmʌn.deɪ/","1️⃣","School starts on Monday.","တနင်္လာနေ့မှာ ကျောင်းစတက်တယ်။"),
        ("Tuesday","အင်္ဂါနေ့","/ˈtuːz.deɪ/","2️⃣","We paint on Tuesday.","အင်္ဂါနေ့မှာ ပန်းချီဆွဲကြတယ်။"),
        ("Wednesday","ဗုဒ္ဓဟူးနေ့","/ˈwɛnz.deɪ/","3️⃣","Wednesday is mid-week.","ဗုဒ္ဓဟူးနေ့က ရက်သတ္တပတ်အလယ်ပါ။"),
        ("Thursday","ကြာသပတေးနေ့","/ˈθɜːrz.deɪ/","4️⃣","We sing songs on Thursday.","ကြာသပတေးနေ့မှာ သီချင်းဆိုကြတယ်။"),
        ("Friday","သောကြာနေ့","/ˈfraɪ.deɪ/","5️⃣","Friday is a cheerful day.","သောကြာနေ့က ပျော်စရာနေ့လေးပါ။"),
        ("Saturday","စနေနေ့","/ˈsæt.ər.deɪ/","6️⃣","I play at the park on Saturday.","စနေနေ့မှာ ပန်းခြံထဲ ကစားတယ်။"),
        ("Sunday","တနင်္ဂနွေနေ့","/ˈsʌn.deɪ/","7️⃣","Sunday is family rest day.","တနင်္ဂနွေနေ့က မိသားစုအနားယူရက်ပါ။"),
    ]),
    mod("g1_vocab", 13, "Simple Vocabulary", "အခြေခံဝေါဟာရများ", "Everyday English words for kids.", "ကလေးတို့နေ့စဉ်သုံး အခြေခံစကားလုံးများ။", "🌟", 0xFFFF9B6A, "vocabulary", [
        ("Sun","နေမင်း","/sʌn/","☀️","The sun shines brightly.","နေမင်းကြီး တောက်ပစွာ ထွန်းလင်းနေတယ်။"),
        ("Water","ရေ","/ˈwɔː.tər/","💧","Drink clean water every day.","နေ့တိုင်း သန့်ရှင်းတဲ့ရေ သောက်ပါ။"),
        ("House","အိမ်","/haʊs/","🏠","Our house has a garden.","တို့အိမ်မှာ ပန်းခြံလေးရှိတယ်။"),
        ("Flower","ပန်း","/ˈflaʊ.ər/","🌸","A pretty pink flower.","လှပတဲ့ ပန်းရောင်ပန်းလေးတစ်ပွင့်။"),
        ("Ball","ဘောလုံး","/bɔːl/","⚽","Kick the ball to me.","ဘောလုံးကို ငါ့ဆီကန်ပေးပါ။"),
        ("Car","ကား","/kɑːr/","🚗","The small car goes fast.","ကားလေးက မြန်မြန်မောင်းသွားတယ်။"),
        ("Cake","ကိတ်မုန့်","/keɪk/","🎂","Happy birthday cake!","မွေးနေ့ကိတ်မုန့်လေးပါ!"),
        ("Toy","ကစားစရာ","/tɔɪ/","🧸","Put your toys away neatly.","ကစားစရာတွေကို သေသေချာချာ ပြန်သိမ်းပါ။"),
    ]),
    mod("g1_greetings", 14, "Basic Greetings", "အခြေခံနှုတ်ဆက်စကားများ", "Polite ways to say hello and goodbye.", "ယဉ်ကျေးစွာ နှုတ်ဆက်ပြောဆိုနည်းများ။", "👋", 0xFFFF7AA2, "greetings", [
        ("Hello","မင်္ဂလာပါ","/həˈloʊ/","👋","Hello, my friend!","မင်္ဂလာပါ သူငယ်ချင်း!"),
        ("Good morning","မင်္ဂလာနံနက်ခင်းပါ","/ɡʊd ˈmɔːr.nɪŋ/","🌅","Good morning, teacher!","မင်္ဂလာနံနက်ခင်းပါ ဆရာမ!"),
        ("Good afternoon","မင်္ဂလာနေ့လယ်ခင်းပါ","/ɡʊd ˌæf.tərˈnuːn/","☀️","Good afternoon, everyone.","အားလုံးပဲ မင်္ဂလာနေ့လယ်ခင်းပါ။"),
        ("Good night","ကောင်းသောညပါ","/ɡʊd naɪt/","🌙","Good night, Mom and Dad.","ကောင်းသောညပါ မေမေနဲ့ဖေဖေ။"),
        ("Thank you","ကျေးဇူးတင်ပါတယ်","/θæŋk juː/","🙏","Thank you for helping me.","ကူညီပေးတဲ့အတွက် ကျေးဇူးတင်ပါတယ်။"),
        ("Sorry","တောင်းပန်ပါတယ်","/ˈsɒr.i/","💐","I am sorry for being late.","နောက်ကျသွားလို့ တောင်းပန်ပါတယ်။"),
        ("Goodbye","တာ့တာ / နှုတ်ဆက်ပါတယ်","/ɡʊdˈbaɪ/","🙋","Goodbye! See you tomorrow.","တာ့တာ! မနက်ဖြန်မှ တွေ့မယ်နော်။"),
    ]),
]

path = Path("assets/data/grade1_lessons.json")
base = json.loads(path.read_text(encoding="utf-8"))
lessons = [l for l in base["lessons"] if l["order"] <= 3] + extra
lessons.sort(key=lambda x: x["order"])
path.write_text(json.dumps({"lessons": lessons}, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"✅ Stage 2 (၂/၄) Grade 1 စုစုပေါင်း သင်ခန်းစာ {len(lessons)} ခု ပြီးပါပြီ")
