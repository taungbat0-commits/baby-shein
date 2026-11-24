import json
from pathlib import Path

def mk_item(i, en, my, ph, em, ex_en, ex_my, color=None, note=None):
    d = {
        "id": i, "english": en, "myanmar": my, "phonetic": ph, "emoji": em,
        "audioKey": i, "exampleEn": ex_en, "exampleMy": ex_my, "exampleAudioKey": f"{i}_ex"
    }
    if color is not None:
        d["colorHex"] = color
    if note is not None:
        d["grammarNote"] = note
    return d

alpha_rows = [
    ("A","အေ","/eɪ/","🍎","A is for Apple.","A ဆိုတာ ပန်းသီးလေးပါ။"),
    ("B","ဘီ","/biː/","⚽","B is for Ball.","B ဆိုတာ ဘောလုံးလေးပါ။"),
    ("C","စီ","/siː/","🐱","C is for Cat.","C ဆိုတာ ကြောင်လေးပါ။"),
    ("D","ဒီ","/diː/","🐶","D is for Dog.","D ဆိုတာ ခွေးလေးပါ။"),
    ("E","အီး","/iː/","🥚","E is for Egg.","E ဆိုတာ ကြက်ဥလေးပါ။"),
    ("F","အက်ဖ်","/ɛf/","🐟","F is for Fish.","F ဆိုတာ ငါးလေးပါ။"),
    ("G","ဂျီ","/dʒiː/","🐐","G is for Goat.","G ဆိုတာ ဆိတ်ကလေးပါ။"),
    ("H","အိတ်ချ်","/eɪtʃ/","👒","H is for Hat.","H ဆိုတာ ဦးထုပ်လေးပါ။"),
    ("I","အိုင်","/aɪ/","🍦","I is for Ice cream.","I ဆိုတာ ရေခဲမုန့်လေးပါ။"),
    ("J","ဂျေ","/dʒeɪ/","🧃","J is for Juice.","J ဆိုတာ ဖျော်ရည်လေးပါ။"),
    ("K","ကေ","/keɪ/","🪁","K is for Kite.","K ဆိုတာ စွန်လေးပါ။"),
    ("L","အယ်လ်","/ɛl/","🦁","L is for Lion.","L ဆိုတာ ခြင်္သေ့ကြီးပါ။"),
    ("M","အမ်","/ɛm/","🥭","M is for Mango.","M ဆိုတာ သရက်သီးလေးပါ။"),
    ("N","အန်","/ɛn/","🪹","N is for Nest.","N ဆိုတာ ငှက်သိုက်လေးပါ။"),
    ("O","အို","/oʊ/","🍊","O is for Orange.","O ဆိုတာ လိမ္မော်သီးလေးပါ။"),
    ("P","ပီ","/piː/","✏️","P is for Pencil.","P ဆိုတာ ခဲတံလေးပါ။"),
    ("Q","ကျူ","/kjuː/","👑","Q is for Queen.","Q ဆိုတာ ဘုရင်မလေးပါ။"),
    ("R","အာ","/ɑːr/","🐰","R is for Rabbit.","R ဆိုတာ ယုန်လေးပါ။"),
    ("S","အက်စ်","/ɛs/","☀️","S is for Sun.","S ဆိုတာ နေမင်းကြီးပါ။"),
    ("T","တီ","/tiː/","🐯","T is for Tiger.","T ဆိုတာ ကျားကြီးပါ။"),
    ("U","ယူ","/juː/","☂️","U is for Umbrella.","U ဆိုတာ ထီးလေးပါ။"),
    ("V","ဗီ","/viː/","🚐","V is for Van.","V ဆိုတာ ဗင်ကားလေးပါ။"),
    ("W","ဒဗလျူ","/ˈdʌb.əl.juː/","🍉","W is for Watermelon.","W ဆိုတာ ဖရဲသီးလေးပါ။"),
    ("X","အိတ်စ်","/ɛks/","🩻","X is for X-ray.","X ဆိုတာ ဓာတ်မှန်လေးပါ။"),
    ("Y","ဝိုင်","/waɪ/","🪀","Y is for Yo-yo.","Y ဆိုတာ ယိုယိုကစားစရာပါ။"),
    ("Z","ဇက်","/ziː/","🦓","Z is for Zebra.","Z ဆိုတာ မြင်းကျားလေးပါ။"),
]

phonics_rows = [
    ("a - ant","အဲ - ပုရွက်ဆိတ်","/æ/","🐜","An ant is tiny.","ပုရွက်ဆိတ်လေးက သေးသေးလေးပါ။"),
    ("b - bag","ဘ - လွယ်အိတ်","/b/","🎒","My bag is blue.","ငါ့လွယ်အိတ်က အပြာရောင်ပါ။"),
    ("c - cup","ခ - ခွက်","/k/","☕","This cup is warm.","ဒီခွက်လေးက နွေးနေတယ်။"),
    ("d - duck","ဒ - ဘဲ","/d/","🦆","The duck can swim.","ဘဲလေးက ရေကူးတတ်တယ်။"),
    ("e - elephant","အဲ့ - ဆင်","/ɛ/","🐘","An elephant is big.","ဆင်ကြီးက အရမ်းကြီးတယ်။"),
    ("f - frog","ဖ - ဖား","/f/","🐸","The frog jumps high.","ဖားလေးက အမြင့်ကြီးခုန်တယ်။"),
    ("g - grape","ဂ - စပျစ်သီး","/ɡ/","🍇","Sweet purple grapes.","ချိုတဲ့ ခရမ်းရောင် စပျစ်သီးတွေပါ။"),
    ("h - house","ဟ - အိမ်","/h/","🏠","I love my house.","ငါ့အိမ်လေးကို ချစ်တယ်။"),
    ("i - igloo","အိ - ရေခဲအိမ်","/ɪ/","🧊","A cold white igloo.","အေးမြတဲ့ အဖြူရောင် ရေခဲအိမ်လေးပါ။"),
    ("j - jam","ဂျ - ယို","/dʒ/","🍓","I eat berry jam.","ငါ ဘယ်ရီယို စားတယ်။"),
    ("k - key","ခ - သော့","/k/","🔑","Here is the key.","ဒီမှာ သော့လေးပါ။"),
    ("l - leaf","လ - သစ်ရွက်","/l/","🍃","A green leaf falls.","သစ်ရွက်စိမ်းလေး ကြွေကျတယ်။"),
    ("m - moon","မ - လမင်း","/m/","🌙","Look at the bright moon.","လင်းနေတဲ့ လမင်းကြီးကို ကြည့်ပါ။"),
    ("n - nose","န - နှာခေါင်း","/n/","👃","Touch your little nose.","မင်းရဲ့နှာခေါင်းလေးကို ထိကြည့်ပါ။"),
    ("o - octopus","အော့ - ရေဘဝဲ","/ɒ/","🐙","An octopus has eight arms.","ရေဘဝဲမှာ လက်တံ ၈ ချောင်းရှိတယ်။"),
    ("p - pig","ပ - ဝက်","/p/","🐷","A pink baby pig.","ပန်းရောင် ဝက်ကလေးပါ။"),
    ("r - rain","ရ - မိုး","/r/","🌧️","Rain helps flowers grow.","မိုးရေက ပန်းလေးတွေကို ကြီးထွားစေတယ်။"),
    ("s - star","စ - ကြယ်","/s/","⭐","A shiny gold star.","တောက်ပတဲ့ ရွှေကြယ်လေးပါ။"),
    ("t - tree","တ - သစ်ပင်","/t/","🌳","A tall green tree.","မြင့်မားတဲ့ သစ်ပင်စိမ်းကြီးပါ။"),
    ("u - up","အ - အပေါ်","/ʌ/","⬆️","Hands up high.","လက်တွေ အပေါ်မြှောက်လိုက်ပါ!"),
]

ones_en = ["","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"]
teens_en = ["Ten","Eleven","Twelve","Thirteen","Fourteen","Fifteen","Sixteen","Seventeen","Eighteen","Nineteen"]
tens_en = ["","","Twenty","Thirty","Forty","Fifty","Sixty","Seventy","Eighty","Ninety"]
ones_my = ["","တစ်","နှစ်","သုံး","လေး","ငါး","ခြောက်","ခုနစ်","ရှစ်","ကိုး"]
mm_dig = str.maketrans("0123456789", "၀၁၂၃၄၅၆၇၈၉")

def num_en(n):
    if n == 100: return "One hundred"
    if n < 10: return ones_en[n]
    if n < 20: return teens_en[n - 10]
    t, o = divmod(n, 10)
    return tens_en[t] if o == 0 else f"{tens_en[t]}-{ones_en[o].lower()}"

def num_my(n):
    d = str(n).translate(mm_dig)
    if n == 100: w = "တစ်ရာ"
    elif n < 10: w = ones_my[n]
    elif n == 10: w = "တစ်ဆယ်"
    elif n < 20: w = f"ဆယ့်{ones_my[n - 10]}"
    else:
        t, o = divmod(n, 10)
        w = f"{ones_my[t]}ဆယ်" if o == 0 else f"{ones_my[t]}ဆယ့်{ones_my[o]}"
    return f"{d} ({w})"

num_items = []
for n in range(1, 101):
    en = num_en(n)
    my = num_my(n)
    d = str(n).translate(mm_dig)
    ex_en = f"I can count to {en.lower()}." if n > 1 else "I have one bright star."
    ex_my = f"ငါ {d} အထိ ရေတွက်တတ်တယ်။" if n > 1 else "ငါ့မှာ ကြယ်လေး တစ်လုံးရှိတယ်။"
    num_items.append(mk_item(f"g1_num_{n}", en, my, str(n), "🔢", ex_en, ex_my))

lessons = [
    {
        "id": "g1_alphabet", "grade": 1, "order": 1,
        "titleEn": "Alphabet A-Z", "titleMy": "အင်္ဂလိပ်အက္ခရာ A မှ Z",
        "descriptionEn": "Learn all 26 English letters with fun pictures.",
        "descriptionMy": "ပုံလှလှလေးတွေနဲ့ အင်္ဂလိပ်အက္ခရာ ၂၆ လုံးကို လေ့လာကြမယ်။",
        "icon": "🔤", "colorHex": 0xFF4FB3FF, "category": "alphabet",
        "items": [mk_item(f"g1_alpha_{r[0].lower()}", r[0], r[1], r[2], r[3], r[4], r[5]) for r in alpha_rows]
    },
    {
        "id": "g1_phonics", "grade": 1, "order": 2,
        "titleEn": "Alphabet Pronunciation", "titleMy": "အက္ခရာအသံထွက်များ",
        "descriptionEn": "Hear how each letter sounds inside words.",
        "descriptionMy": "အက္ခရာတစ်လုံးချင်းစီရဲ့ အသံထွက်လေးတွေကို နားထောင်လေ့ကျင့်မယ်။",
        "icon": "🔊", "colorHex": 0xFFFF7AA2, "category": "pronunciation",
        "items": [mk_item(f"g1_ph_{i+1}", r[0], r[1], r[2], r[3], r[4], r[5]) for i, r in enumerate(phonics_rows)]
    },
    {
        "id": "g1_numbers", "grade": 1, "order": 3,
        "titleEn": "Numbers 1-100", "titleMy": "ဂဏန်းများ ၁ မှ ၁၀၀",
        "descriptionEn": "Count from 1 to 100 in English and Myanmar.",
        "descriptionMy": "၁ ကနေ ၁၀၀ အထိ အင်္ဂလိပ်လို ရေတွက်ကြမယ်။",
        "icon": "🔢", "colorHex": 0xFFFFCA3A, "category": "numbers",
        "items": num_items
    },
]

Path("assets/data/grade1_lessons.json").write_text(
    json.dumps({"lessons": lessons}, ensure_ascii=False, indent=2), encoding="utf-8"
)
print("✅ Stage 2 (၁/၄) Grade 1 Lessons 1-3 ရေးပြီးပါပြီ")
