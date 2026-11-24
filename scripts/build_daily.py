import json
from pathlib import Path

rows = [
    ("d1","Good morning, Mom and Dad!","မင်္ဂလာနံနက်ခင်းပါ မေမေနဲ့ဖေဖေ!","Morning","မနက်အိပ်ရာထချိန်","🌅","Good morning, sweetheart!","မင်္ဂလာနံနက်ခင်းပါ သားလေး/သမီးလေး!"),
    ("d2","Please pass me the water.","ရေလေး ကမ်းပေးပါနော်။","Mealtime","ထမင်းစားချိန်","💧","Here you go!","ရော့ ဒီမှာနော်!"),
    ("d3","Thank you very much!","ကျေးဇူးအများကြီးတင်ပါတယ်!","Polite","ယဉ်ကျေးစွာပြောခြင်း","🙏","You are welcome!","ရပါတယ်ကွယ်!"),
    ("d4","Excuse me, teacher.","ခွင့်ပြုပါ ဆရာမ။","Classroom","စာသင်ခန်းထဲ","🙋","Yes, how can I help you?","ဟုတ်ကဲ့ ဘာကူညီပေးရမလဲ?"),
    ("d5","May I drink water, please?","ရေသောက်ခွင့်ပြုပါနော်။","Classroom","စာသင်ခန်းထဲ","🥤","Yes, you may.","ဟုတ်ကဲ့ သောက်နိုင်ပါတယ်။"),
    ("d6","Let us play together!","အတူတူ ကစားကြရအောင်!","Playtime","ကစားချိန်","⚽","Yay! That sounds fun!","ရေး! ပျော်စရာကြီးပဲ!"),
    ("d7","I am hungry.","ကျွန်တော်/မ ဗိုက်ဆာနေပြီ။","Home","အိမ်မှာ","🍚","Let us eat dinner soon.","ခဏနေရင် ညစာစားကြမယ်နော်။"),
    ("d8","I finished my homework.","အိမ်စာလုပ်ပြီးပါပြီ။","Study","စာကျက်ချိန်","📚","Great job! I am proud of you.","အရမ်းတော်တယ်! ဂုဏ်ယူပါတယ်။"),
    ("d9","See you tomorrow!","မနက်ဖြန်မှ တွေ့မယ်နော်!","Going Home","ကျောင်းဆင်းချိန်","👋","Bye! Have a nice evening.","တာ့တာ! ပျော်ရွှင်သောညနေခင်းဖြစ်ပါစေ။"),
    ("d10","Good night, sweet dreams!","ကောင်းသောညပါ အိပ်မက်လှလှမက်ပါစေ!","Bedtime","အိပ်ရာဝင်ချိန်","🌙","Good night! Sleep well.","ကောင်းသောညပါ ကောင်းကောင်းအိပ်နော်။"),
    ("d11","Can I borrow your pencil?","မင်းခဲတံ ခဏငှားလို့ရမလား?","Classroom","စာသင်ခန်းထဲ","✏️","Of course, here it is.","ရတာပေါ့ ရော့ ဒီမှာ။"),
    ("d12","I love learning English!","အင်္ဂလိပ်စာ သင်ရတာ အရမ်းကြိုက်တယ်!","Learning","သင်ယူချိန်","⭐","Keep going, little star!","ဆက်ကြိုးစားထားနော် ကြယ်ပွင့်လေး!"),
]

phrases = [
    {
        "id": r[0], "english": r[1], "myanmar": r[2],
        "situationEn": r[3], "situationMy": r[4], "emoji": r[5],
        "audioKey": f"daily_{r[0]}", "responseEn": r[6], "responseMy": r[7]
    }
    for r in rows
]

Path("assets/data/daily_english.json").write_text(
    json.dumps({"phrases": phrases}, ensure_ascii=False, indent=2), encoding="utf-8"
)

g1 = json.loads(Path("assets/data/grade1_lessons.json").read_text(encoding="utf-8"))
g2 = json.loads(Path("assets/data/grade2_lessons.json").read_text(encoding="utf-8"))
print(f"✅ Grade 1: {len(g1['lessons'])} lessons | Grade 2: {len(g2['lessons'])} lessons | Daily: {len(phrases)} phrases")
