import json
from pathlib import Path

def mk(i, en, my, ph, em, ex_en, ex_my, note=None):
    d = {
        "id": i, "english": en, "myanmar": my, "phonetic": ph, "emoji": em,
        "audioKey": i, "exampleEn": ex_en, "exampleMy": ex_my, "exampleAudioKey": f"{i}_ex"
    }
    if note:
        d["grammarNote"] = note
    return d

def mod(mid, order, ten, tmy, den, dmy, icon, col, cat, rows):
    items = [mk(f"{mid}_{idx}", r[0], r[1], r[2], r[3], r[4], r[5], r[6] if len(r) > 6 else None)
             for idx, r in enumerate(rows, 1)]
    return {
        "id": mid, "grade": 2, "order": order, "titleEn": ten, "titleMy": tmy,
        "descriptionEn": den, "descriptionMy": dmy, "icon": icon,
        "colorHex": col, "category": cat, "items": items
    }

lessons = [
    mod("g2_common", 1, "Common English Words", "အသုံးများသော အင်္ဂလိပ်စကားလုံးများ", "Useful words for Grade 2 learners.", "Grade 2 ကလေးတို့အတွက် အသုံးများတဲ့ စကားလုံးများ။", "📘", 0xFF4FB3FF, "vocabulary", [
        ("Happy","ပျော်ရွှင်သော","/ˈhæp.i/","😊","I feel happy today.","ဒီနေ့ ငါ ပျော်ရွှင်နေတယ်။"),
        ("Friend","သူငယ်ချင်း","/frɛnd/","🤝","Su Su is my best friend.","စုစုက ငါ့အချစ်ဆုံးသူငယ်ချင်းပါ။"),
        ("Clean","သန့်ရှင်းသော","/kliːn/","✨","Keep our classroom clean.","စာသင်ခန်းကို သန့်သန့်ရှင်းရှင်းထားပါ။"),
        ("Fast","မြန်သော","/fæst/","⚡","The rabbit runs very fast.","ယုန်လေးက အရမ်းမြန်မြန်ပြေးတယ်။"),
        ("Kind","ကြင်နာသော","/kaɪnd/","💖","Be kind to animals.","တိရစ္ဆာန်လေးတွေကို ကြင်နာပါ။"),
        ("Smart","ဉာဏ်ကောင်းသော","/smɑːrt/","🧠","You are a smart student.","မင်းက ဉာဏ်ကောင်းတဲ့ ကျောင်းသားလေးပါ။"),
        ("Small","သေးငယ်သော","/smɔːl/","🐥","A small yellow chick.","ကြက်ပေါက်ဝါ သေးသေးလေး။"),
        ("Big","ကြီးမားသော","/bɪɡ/","🐳","A whale is very big.","ဝေလငါးကြီးက အရမ်းကြီးတယ်။"),
    ]),
    mod("g2_sentences", 2, "Simple Sentences", "ရိုးရှင်းသော ဝါကျများ", "Build short everyday sentences.", "နေ့စဉ်သုံး ဝါကျတိုလေးတွေ ဖွဲ့တတ်အောင် လေ့လာမယ်။", "💬", 0xFFFF7AA2, "sentences", [
        ("I like apples.","ငါ ပန်းသီးကြိုက်တယ်။","","🍎","I like red apples.","ငါ ပန်းသီးနီနီလေးတွေ ကြိုက်တယ်။"),
        ("This is my book.","ဒါ ငါ့စာအုပ်ပါ။","","📖","This is my new book.","ဒါ ငါ့စာအုပ်အသစ်လေးပါ။"),
        ("She can sing.","သူမ သီချင်းဆိုတတ်တယ်။","","🎤","She can sing sweetly.","သူမ သီချင်းချိုချိုလေး ဆိုတတ်တယ်။"),
        ("He is playing.","သူ ကစားနေတယ်။","","⚽","He is playing with a ball.","သူ ဘောလုံးနဲ့ ကစားနေတယ်။"),
        ("We go to school.","တို့တွေ ကျောင်းသွားကြတယ်။","","🏫","We go to school together.","တို့တွေ အတူတူ ကျောင်းသွားကြတယ်။"),
        ("The cat is cute.","ကြောင်လေးက ချစ်စရာကောင်းတယ်။","","🐱","The white cat is cute.","ကြောင်ဖြူလေးက ချစ်စရာကောင်းတယ်။"),
    ]),
    mod("g2_conversations", 3, "Daily Conversations", "နေ့စဉ်စကားပြောခန်းများ", "Short friendly dialogues.", "သူငယ်ချင်းတွေနဲ့ ပြောဆိုနိုင်တဲ့ စကားပြောခန်းတိုများ။", "🗣️", 0xFF38C98F, "conversation", [
        ("What is your name?","မင်းနာမည် ဘယ်လိုခေါ်လဲ?","","🙋","My name is Mg Mg.","ကျွန်တော့်နာမည် မောင်မောင်ပါ။"),
        ("How are you?","နေကောင်းလား?","","😊","I am fine, thank you!","နေကောင်းပါတယ် ကျေးဇူးတင်ပါတယ်။"),
        ("How old are you?","အသက် ဘယ်နှစ်နှစ်ရှိပြီလဲ?","","🎂","I am seven years old.","ကျွန်တော် အသက် ၇ နှစ်ရှိပါပြီ။"),
        ("May I come in?","ဝင်ခွင့်ပြုပါခင်ဗျာ/ရှင်။","","🚪","Yes, please come in.","ဟုတ်ကဲ့ ဝင်လာပါ။"),
        ("Can you help me?","ငါ့ကို ကူညီပေးနိုင်မလား?","","🤝","Sure, I can help you!","ရပါတယ် ငါကူညီပေးမယ်!"),
        ("Nice to meet you.","တွေ့ရတာ ဝမ်းသာပါတယ်။","","🌟","Nice to meet you too.","ငါလည်း တွေ့ရတာ ဝမ်းသာပါတယ်။"),
    ]),
    mod("g2_months", 4, "Days and Months", "နေ့ရက်များနှင့် လများ", "All 12 months of the year.", "တစ်နှစ်တာရှိ လ ၁၂ လကို လေ့လာမယ်။", "🗓️", 0xFFFFCA3A, "months", [
        ("January","ဇန်နဝါရီလ","/ˈdʒæn.ju.ɛr.i/","❄️","January is the first month.","ဇန်နဝါရီလက ပထမဆုံးလပါ။"),
        ("February","ဖေဖော်ဝါရီလ","/ˈfɛb.ru.ɛr.i/","💝","February is a cool month.","ဖေဖော်ဝါရီလက အေးမြတဲ့လပါ။"),
        ("March","မတ်လ","/mɑːrtʃ/","🌼","March begins the warm season.","မတ်လက နွေရာသီအစပါ။"),
        ("April","ဧပြီလ","/ˈeɪ.prəl/","💦","Thingyan festival is in April!","သင်္ကြန်ပွဲတော်က ဧပြီလမှာပါ!"),
        ("May","မေလ","/meɪ/","🌦️","Early rain comes in May.","မေလမှာ မိုးဦးကျလာတယ်။"),
        ("June","ဇွန်လ","/dʒuːn/","🎒","Schools open in June.","ဇွန်လမှာ ကျောင်းတွေပြန်ဖွင့်တယ်။"),
        ("July","ဇူလိုင်လ","/dʒuˈlaɪ/","☂️","We bring umbrellas in July.","ဇူလိုင်လမှာ ထီးဆောင်သွားကြတယ်။"),
        ("August","ဩဂုတ်လ","/ˈɔː.ɡəst/","🌧️","Rain falls softly in August.","ဩဂုတ်လမှာ မိုးအေးအေးလေး ရွာတယ်။"),
        ("September","စက်တင်ဘာလ","/sɛpˈtɛm.bər/","🌿","Trees look fresh in September.","စက်တင်ဘာလမှာ သစ်ပင်တွေ စိမ်းလန်းနေတယ်။"),
        ("October","အောက်တိုဘာလ","/ɒkˈtoʊ.bər/","🏮","Thadingyut lights shine in October.","အောက်တိုဘာလမှာ သီတင်းကျွတ်မီးထွန်းပွဲရှိတယ်။"),
        ("November","နိုဝင်ဘာလ","/noʊˈvɛm.bər/","🎈","Tazaungdaing is in November.","နိုဝင်ဘာလမှာ တန်ဆောင်တိုင်ပွဲတော်ရှိတယ်။"),
        ("December","ဒီဇင်ဘာလ","/dɪˈsɛm.bər/","🎄","December is the last month.","ဒီဇင်ဘာလက နှစ်ကုန်လပါ။"),
    ]),
    mod("g2_weather", 5, "Weather", "ရာသီဥတု", "Talk about today's sky and weather.", "ဒီနေ့ရာသီဥတုအကြောင်း အင်္ဂလိပ်လို ပြောကြမယ်။", "🌦️", 0xFF4FB3FF, "weather", [
        ("Sunny","နေသာသော","/ˈsʌn.i/","☀️","Today is warm and sunny.","ဒီနေ့ နွေးပြီး နေသာတယ်။"),
        ("Rainy","မိုးရွာသော","/ˈreɪ.ni/","🌧️","Wear a raincoat on rainy days.","မိုးရွာတဲ့နေ့မှာ မိုးကာအင်္ကျီဝတ်ပါ။"),
        ("Cloudy","တိမ်ထူသော","/ˈklaʊ.di/","☁️","The sky is cloudy today.","ဒီနေ့ ကောင်းကင်မှာ တိမ်ထူနေတယ်။"),
        ("Windy","လေတိုက်သော","/ˈwɪn.di/","💨","Fly a kite on a windy day.","လေတိုက်တဲ့နေ့မှာ စွန်လွှတ်ကြမယ်။"),
        ("Hot","ပူသော","/hɒt/","🥵","Drink water when it is hot.","ပူတဲ့အခါ ရေများများသောက်ပါ။"),
        ("Cold","အေးသော","/koʊld/","🧥","Wear a sweater when it is cold.","အေးတဲ့အခါ အနွေးထည်ဝတ်ပါ။"),
        ("Rainbow","သက်တံ","/ˈreɪn.boʊ/","🌈","A rainbow appears after rain.","မိုးတိတ်ပြီးရင် သက်တံလေး ပေါ်လာတယ်။"),
    ]),
    mod("g2_food", 6, "Food and Drinks", "အစားအစာနှင့် အချိုရည်များ", "Tasty meals and healthy drinks.", "အရသာရှိတဲ့ အစားအစာနဲ့ သောက်စရာများ။", "🍜", 0xFFFF9B6A, "food", [
        ("Rice","ထမင်း","/raɪs/","🍚","We eat rice every day.","တို့တွေ နေ့တိုင်း ထမင်းစားကြတယ်။"),
        ("Noodles","ခေါက်ဆွဲ","/ˈnuː.dəlz/","🍜","Hot noodles are delicious.","ခေါက်ဆွဲပူပူလေးက အရမ်းစားကောင်းတယ်။"),
        ("Bread","ပေါင်မုန့်","/brɛd/","🍞","I eat bread for breakfast.","မနက်စာအတွက် ပေါင်မုန့်စားတယ်။"),
        ("Egg","ကြက်ဥ","/ɛɡ/","🍳","A fried egg for lunch.","နေ့လယ်စာအတွက် ကြက်ဥကြော်လေး။"),
        ("Milk","နို့","/mɪlk/","🥛","Milk helps bones grow strong.","နို့သောက်ရင် အရိုးသန်မာစေတယ်။"),
        ("Juice","သစ်သီးဖျော်ရည်","/dʒuːs/","🧃","Fresh orange juice is sweet.","လိမ္မော်ဖျော်ရည်လတ်လတ်လေးက ချိုတယ်။"),
        ("Soup","ဟင်းချို","/suːp/","🥣","Warm chicken soup.","ကြက်သားဟင်းချို ပူပူနွေးနွေးလေး။"),
        ("Tea","လက်ဖက်ရည်","/tiː/","🍵","Grandpa drinks green tea.","ဘိုးဘိုး ရေနွေးကြမ်း သောက်တယ်။"),
    ]),
    mod("g2_activities", 7, "School Activities", "ကျောင်းတွင်းလှုပ်ရှားမှုများ", "Fun actions we do at school.", "ကျောင်းမှာ လုပ်လေ့ရှိတဲ့ လှုပ်ရှားမှုများ။", "🎨", 0xFF9B7BFF, "activities", [
        ("Read","ဖတ်သည်","/riːd/","📖","I read a story book.","ငါ ပုံပြင်စာအုပ် ဖတ်တယ်။"),
        ("Write","ရေးသည်","/raɪt/","✍️","Write your name neatly.","မင်းနာမည်ကို လှလှပပ ရေးပါ။"),
        ("Draw","ပုံဆွဲသည်","/drɔː/","🖍️","Let us draw a happy sun.","ပြုံးနေတဲ့ နေမင်းပုံ ဆွဲကြရအောင်။"),
        ("Sing","သီချင်းဆိုသည်","/sɪŋ/","🎵","We sing the ABC song.","တို့တွေ ABC သီချင်း ဆိုကြတယ်။"),
        ("Count","ရေတွက်သည်","/kaʊnt/","🔢","Count the apples on the desk.","စားပွဲပေါ်က ပန်းသီးတွေကို ရေတွက်ပါ။"),
        ("Listen","နားထောင်သည်","/ˈlɪs.ən/","🎧","Listen carefully to the teacher.","ဆရာမပြောတာကို ဂရုတစိုက် နားထောင်ပါ။"),
        ("Play","ကစားသည်","/pleɪ/","🛝","Friends play during break time.","မုန့်စားဆင်းချိန်မှာ သူငယ်ချင်းတွေ ကစားကြတယ်။"),
    ]),
    mod("g2_pronouns", 8, "Pronouns", "နာမ်စားများ", "Learn I, You, He, She, It, We, They.", "I, You, He, She, It, We, They သုံးနည်းများ။", "👤", 0xFFFF7AA2, "grammar", [
        ("I","ကျွန်တော် / ကျွန်မ","/aɪ/","🙋","I am a Grade 2 student.","ငါက Grade 2 ကျောင်းသားပါ။","မိမိကိုယ်ကို ရည်ညွှန်းတဲ့အခါ I ကိုသုံးပါ။"),
        ("You","သင် / မင်း","/juː/","👉","You are very kind.","မင်းက အရမ်းကြင်နာတတ်တယ်။","တစ်ဖက်လူကို ပြောတဲ့အခါ You ကိုသုံးပါ။"),
        ("He","သူ (ယောက်ျားလေး)","/hiː/","👦","He is my brother.","သူက ငါ့အစ်ကိုပါ။","ယောက်ျားလေးတစ်ဦးအတွက် He ကိုသုံးပါ။"),
        ("She","သူမ (မိန်းကလေး)","/ʃiː/","👧","She is reading a book.","သူမ စာအုပ်ဖတ်နေတယ်။","မိန်းကလေးတစ်ဦးအတွက် She ကိုသုံးပါ။"),
        ("It","၎င်း (အရာဝတ္ထု/တိရစ္ဆာန်)","/ɪt/","🐶","It is a fluffy puppy.","အဲဒါ အမွှေးပွခွေးပေါက်လေးပါ။","တိရစ္ဆာန်နဲ့ အရာဝတ္ထုတစ်ခုအတွက် It ကိုသုံးပါ။"),
        ("We","ကျွန်ုပ်တို့","/wiː/","👨‍👩‍👧","We are happy friends.","တို့တွေက ပျော်ရွှင်တဲ့ သူငယ်ချင်းတွေပါ။","မိမိပါဝင်တဲ့ အများအတွက် We ကိုသုံးပါ။"),
        ("They","သူတို့","/ðeɪ/","👧👦","They are playing football.","သူတို့ ဘောလုံးကန်နေကြတယ်။","အခြားသူအများ သို့မဟုတ် အရာဝတ္ထုအများအတွက် They ကိုသုံးပါ။"),
    ]),
    mod("g2_grammar", 9, "Basic Grammar", "အခြေခံသဒ္ဒါ", "Easy rules: am / is / are and a / an.", "am, is, are နဲ့ a, an လွယ်ကူတဲ့ သဒ္ဒါစည်းမျဉ်းများ။", "📝", 0xFF38C98F, "grammar", [
        ("I am","ကျွန်တော်/မ ဖြစ်သည်","","🌟","I am seven years old.","ငါ အသက် ၇ နှစ်ရှိပြီ။","I နဲ့ဆိုရင် အမြဲ am တွဲသုံးပါ။"),
        ("He is / She is","သူ / သူမ ဖြစ်သည်","","👦","She is my teacher.","သူမက ငါ့ဆရာမပါ။","He, She, It တစ်ခုတည်းဆို is သုံးပါ။"),
        ("We are / They are","တို့ / သူတို့ ဖြစ်ကြသည်","","👫","They are good students.","သူတို့က ကျောင်းသားကောင်းလေးတွေပါ။","You, We, They အများဆို are သုံးပါ။"),
        ("a + consonant","a (ဗျည်းသံရှေ့)","","🐱","I see a cat and a dog.","ငါ ကြောင်တစ်ကောင်နဲ့ ခွေးတစ်ကောင် မြင်တယ်။","ဗျည်းသံနဲ့စတဲ့ တစ်ခုတည်းစကားလုံးရှေ့ a ထည့်ပါ။"),
        ("an + vowel","an (a, e, i, o, u ရှေ့)","","🍎","She eats an apple.","သူမ ပန်းသီးတစ်လုံး စားတယ်။","a, e, i, o, u သရသံရှေ့မှာ an ထည့်ပါ။"),
        ("This / That","ဒီဟာ / ဟိုဟာ","","☝️","This is a pen. That is a tree.","ဒါ ဘောပင်ပါ။ ဟိုဟာ သစ်ပင်ပါ။","အနီးဆို This၊ အဝေးဆို That သုံးပါ။"),
    ]),
    mod("g2_qa", 10, "Question and Answer", "အမေးနှင့်အဖြေ", "Ask clear questions and answer politely.", "မေးခွန်းမေးနည်းနဲ့ ပြန်ဖြေနည်းများ။", "❓", 0xFFFFCA3A, "qa", [
        ("What is this?","ဒါ ဘာလဲ?","","📦","It is a pencil box.","အဲဒါ ခဲတံဘူးလေးပါ။"),
        ("Where is the cat?","ကြောင်လေး ဘယ်မှာလဲ?","","🐱","The cat is under the chair.","ကြောင်လေးက ကုလားထိုင်အောက်မှာပါ။"),
        ("Who is she?","သူမက ဘယ်သူလဲ?","","👩","She is my mother.","သူမက ငါ့မေမေပါ။"),
        ("Do you like mangoes?","သရက်သီး ကြိုက်လား?","","🥭","Yes, I do!","ဟုတ်ကဲ့ ကြိုက်ပါတယ်!"),
        ("Can you swim?","ရေကူးတတ်လား?","","🏊","Yes, I can swim.","ဟုတ်ကဲ့ ရေကူးတတ်ပါတယ်။"),
        ("How many books?","စာအုပ် ဘယ်နှစ်အုပ်လဲ?","","📚","There are three books.","စာအုပ် ၃ အုပ်ရှိပါတယ်။"),
    ]),
    mod("g2_plural", 11, "Singular and Plural", "အနည်းကိန်းနှင့် အများကိန်း", "One item vs many items (+s / +es).", "တစ်ခုတည်းနဲ့ အများကြီး ပြောနည်းများ။", "🔢", 0xFF9B7BFF, "grammar", [
        ("Cat → Cats","ကြောင် ၁ ကောင် → ကြောင်များ","","🐱","One cat, two cats.","ကြောင် ၁ ကောင်၊ ကြောင် ၂ ကောင်။","အများကိန်းလုပ်ဖို့ နောက်က s ထည့်ပါ။"),
        ("Book → Books","စာအုပ် ၁ အုပ် → စာအုပ်များ","","📚","I have five books.","ငါ့မှာ စာအုပ် ၅ အုပ်ရှိတယ်။","အများစုမှာ s ထည့်ရုံပါပဲ။"),
        ("Apple → Apples","ပန်းသီး ၁ လုံး → ပန်းသီးများ","","🍎","Three sweet apples.","ချိုတဲ့ ပန်းသီး ၃ လုံး။","နောက်က s ထည့်ပါ။"),
        ("Bus → Buses","ဘတ်စ်ကား ၁ စီး → ဘတ်စ်ကားများ","","🚌","Two yellow buses.","အဝါရောင် ဘတ်စ်ကား ၂ စီး။","s, sh, ch, x နဲ့ဆုံးရင် es ထည့်ပါ။"),
        ("Box → Boxes","သေတ္တာ ၁ လုံး → သေတ္တာများ","","📦","Put toys in the boxes.","ကစားစရာတွေကို သေတ္တာတွေထဲထည့်ပါ။","x နဲ့ဆုံးလို့ es ထည့်ပါ။"),
        ("Child → Children","ကလေး ၁ ဦး → ကလေးများ","","👧👦","Happy children are playing.","ပျော်ရွှင်တဲ့ ကလေးတွေ ကစားနေကြတယ်။","အထူးအများကိန်းမို့ အလွတ်မှတ်ထားပါ။"),
    ]),
    mod("g2_reading", 12, "Simple Reading", "ရိုးရှင်းသော စာဖတ်လေ့ကျင့်ခန်း", "Mini stories with Myanmar translation.", "မြန်မာဘာသာပြန်ပါတဲ့ ပုံပြင်တို စာဖတ်လေ့ကျင့်ခန်းများ။", "📖", 0xFF4FB3FF, "reading", [
        ("My Little Puppy","ငါ့ရဲ့ ခွေးပေါက်လေး","","🐶","I have a brown puppy. His name is Bobo. He likes to run in the garden.","ငါ့မှာ အညိုရောင်ခွေးပေါက်လေး တစ်ကောင်ရှိတယ်။ သူ့နာမည်က ဘိုဘိုပါ။ သူက ပန်းခြံထဲမှာ ပြေးရတာကြိုက်တယ်။"),
        ("A Sunny Morning","နေသာသော မနက်ခင်း","","🌅","The sun is up. Birds sing in the green tree. I wash my face and eat breakfast.","နေမင်းကြီး ထွက်လာပြီ။ သစ်ပင်စိမ်းပေါ်မှာ ငှက်ကလေးတွေ သီချင်းဆိုနေတယ်။ ငါ မျက်နှာသစ်ပြီး မနက်စာစားတယ်။"),
        ("At My School","ငါ့ကျောင်းလေးမှာ","","🏫","My school is clean and bright. I read books with my friends. Our teacher is very kind.","ငါ့ကျောင်းလေးက သန့်ရှင်းပြီး လင်းထိန်နေတယ်။ သူငယ်ချင်းတွေနဲ့ စာအုပ်ဖတ်ကြတယ်။ တို့ဆရာမက အရမ်းကြင်နာတတ်တယ်။"),
        ("Fruit Basket","သစ်သီးခြင်းတောင်း","","🧺","Mom brings a basket of fruit. There are two mangoes, three apples, and yellow bananas.","မေမေ သစ်သီးခြင်းတစ်လုံး ယူလာတယ်။ သရက်သီး ၂ လုံး၊ ပန်းသီး ၃ လုံးနဲ့ ငှက်ပျောသီးဝါလေးတွေ ပါတယ်။"),
        ("Rainy Day Fun","မိုးရွာနေ့ ပျော်စရာ","","🌧️","Rain falls outside the window. I stay warm inside and draw a colorful rainbow.","ပြတင်းပေါက်အပြင်မှာ မိုးရွာနေတယ်။ ငါ အိမ်ထဲမှာ နွေးနွေးထွေးထွေးနေပြီး ရောင်စုံသက်တံပုံ ဆွဲနေတယ်။"),
    ]),
]

Path("assets/data/grade2_lessons.json").write_text(
    json.dumps({"lessons": lessons}, ensure_ascii=False, indent=2), encoding="utf-8"
)
print(f"✅ Stage 2 (၃/၄) Grade 2 စုစုပေါင်း သင်ခန်းစာ {len(lessons)} ခု ပြီးပါပြီ")
