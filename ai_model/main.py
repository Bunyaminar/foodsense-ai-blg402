from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import joblib
import json
import numpy as np

app = FastAPI(title="FoodsenseAI ML API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

score_model = joblib.load("health_score_model.pkl")
category_model = joblib.load("category_model.pkl")
scaler = joblib.load("scaler.pkl")
with open("features.json") as f:
    features = json.load(f)

ADDITIVES = {
    'e102': {'name': 'Tartrazin', 'risk': 'yuksek', 'desc': 'Sari boya, hiperaktivite'},
    'e104': {'name': 'Kinolin Sarisi', 'risk': 'yuksek', 'desc': 'Sari boya, alerji'},
    'e110': {'name': 'Sunset Yellow', 'risk': 'yuksek', 'desc': 'Turuncu boya, alerji'},
    'e120': {'name': 'Karmin', 'risk': 'orta', 'desc': 'Kirmizi boya, bocekten'},
    'e122': {'name': 'Azorubine', 'risk': 'yuksek', 'desc': 'Kirmizi boya, hiperaktivite'},
    'e124': {'name': 'Ponceau 4R', 'risk': 'yuksek', 'desc': 'Kirmizi boya, kanserojenik'},
    'e129': {'name': 'Allura Red', 'risk': 'yuksek', 'desc': 'Kirmizi boya, hiperaktivite'},
    'e150d': {'name': 'Amonyak Karamel', 'risk': 'yuksek', 'desc': 'Gazli icecek boyasi, 4-MEI riski'},
    'e211': {'name': 'Sodyum Benzoat', 'risk': 'yuksek', 'desc': 'Koruyucu, kanser riski'},
    'e220': {'name': 'Sulfur Dioksit', 'risk': 'orta', 'desc': 'Koruyucu, astim riski'},
    'e250': {'name': 'Sodyum Nitrit', 'risk': 'yuksek', 'desc': 'Koruyucu, kanser riski'},
    'e252': {'name': 'Potasyum Nitrat', 'risk': 'yuksek', 'desc': 'Koruyucu, kanser riski'},
    'e320': {'name': 'BHA', 'risk': 'yuksek', 'desc': 'Antioksidan, kanserojenik'},
    'e321': {'name': 'BHT', 'risk': 'orta', 'desc': 'Antioksidan, hormonal bozukluk'},
    'e338': {'name': 'Fosforik Asit', 'risk': 'yuksek', 'desc': 'Asit duzenleyici, kemik erimesi'},
    'e407': {'name': 'Karragenan', 'risk': 'orta', 'desc': 'Kalinlastirici, sindirim sorunu'},
    'e621': {'name': 'MSG', 'risk': 'orta', 'desc': 'Lezzet artirici, MSG sendromu'},
    'e951': {'name': 'Aspartam', 'risk': 'orta', 'desc': 'Tatlandirici, saglik riski'},
    'e952': {'name': 'Siklamat', 'risk': 'yuksek', 'desc': 'Tatlandirici, yasakli ulkeler'},
}

UNHEALTHY_KEYWORDS = [
    'hidrojenize', 'trans yag', 'yuksek fruktozlu misir surubu',
    'palm yagi', 'modifiye nisasta', 'sodyum nitrat',
]

HEALTHY_KEYWORDS = [
    'vitamin', 'omega', 'probiotik', 'tam tahil',
    'tam bugday', 'yulaf', 'lif', 'antioksidan',
]

class AnalyzeRequest(BaseModel):
    name: str
    ingredients: Optional[str] = ""
    sugar_100g: Optional[float] = 0
    fat_100g: Optional[float] = 0
    salt_100g: Optional[float] = 0
    protein_100g: Optional[float] = 0
    fiber_100g: Optional[float] = 0
    energy_100g: Optional[float] = 0
    nova_group: Optional[int] = 4
    has_high_risk_additives: Optional[int] = 0
    has_medium_risk_additives: Optional[int] = 0
    allergens: Optional[List[str]] = []
    user_allergens: Optional[List[str]] = []
    user_diet: Optional[str] = ''

class AnalyzeResponse(BaseModel):
    health_score: int
    category: str
    category_label: str
    warnings: List[str]
    positives: List[str]
    suggestions: List[str]
    detected_additives: List[dict]
    allergen_warnings: List[str]
    summary: str

def build_features(req, detected_high, detected_medium, detected_low):
    ing = (req.ingredients or "").lower()
    sugar_protein_ratio = req.sugar_100g / (req.protein_100g + 1)
    fat_protein_ratio = req.fat_100g / (req.protein_100g + 1)
    total_bad = detected_high * 3 + detected_medium * 2 + detected_low
    nutrient_density = (req.protein_100g * 2 + req.fiber_100g * 2
                       - req.sugar_100g * 1.5 - req.salt_100g * 10)
    is_processed = 1 if req.nova_group >= 3 else 0
    processing_penalty = req.nova_group * 5

    return np.array([[
        req.sugar_100g, req.fat_100g, req.salt_100g, req.protein_100g,
        req.fiber_100g, req.energy_100g, req.nova_group,
        detected_high, detected_medium, detected_low,
        0, 0, 0, len(req.allergens or []), is_processed,
        sugar_protein_ratio, fat_protein_ratio,
        total_bad, nutrient_density, processing_penalty
    ]])

@app.get("/")
def root():
    return {"message": "FoodsenseAI ML API", "status": "running", "version": "2.0"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "models_loaded": True}

@app.post("/analyze", response_model=AnalyzeResponse)
def analyze(req: AnalyzeRequest):
    ing = (req.ingredients or "").lower()
    warnings = []
    positives = []
    suggestions = []
    detected_additives = []
    allergen_warnings = []

    # E-kodu tara
    detected_high = 0
    detected_medium = 0
    detected_low = 0
    for ecode, info in ADDITIVES.items():
        if ecode in ing:
            detected_additives.append({
                'code': ecode.upper(),
                'name': info['name'],
                'risk': info['risk'],
                'description': info['desc'],
            })
            if info['risk'] == 'yuksek':
                detected_high += 1
                warnings.append(f"{info['name']} ({ecode.upper()}) - Yuksek risk!")
            elif info['risk'] == 'orta':
                detected_medium += 1
                warnings.append(f"{info['name']} ({ecode.upper()}) - Orta risk")
            else:
                detected_low += 1

    # ML tahmin
    X = build_features(req, detected_high, detected_medium, detected_low)
    X_scaled = scaler.transform(X)
    health_score = int(np.clip(score_model.predict(X_scaled)[0], 0, 100))
    category = category_model.predict(X_scaled)[0]

    # Besin degeri analizi
    if req.sugar_100g > 20:
        warnings.append(f"Cok yuksek seker: {req.sugar_100g}g/100g")
        health_score = max(0, health_score - 10)
    elif req.sugar_100g > 10:
        warnings.append(f"Yuksek seker: {req.sugar_100g}g/100g")
        health_score = max(0, health_score - 5)
    elif req.sugar_100g < 5:
        positives.append(f"Dusuk seker: {req.sugar_100g}g/100g")

    if req.salt_100g > 1.5:
        warnings.append(f"Yuksek tuz: {req.salt_100g}g/100g")
        health_score = max(0, health_score - 8)
    elif req.salt_100g < 0.5:
        positives.append("Dusuk tuz icerigi")

    if req.fat_100g > 20:
        warnings.append(f"Yuksek yag: {req.fat_100g}g/100g")
    elif req.fat_100g < 5:
        positives.append("Dusuk yag icerigi")

    if req.protein_100g > 10:
        positives.append(f"Iyi protein kaynagi: {req.protein_100g}g/100g")
        health_score = min(100, health_score + 5)

    if req.fiber_100g > 3:
        positives.append(f"Iyi lif kaynagi: {req.fiber_100g}g/100g")
        health_score = min(100, health_score + 5)

    # Keyword analizi
    for kw in UNHEALTHY_KEYWORDS:
        if kw in ing:
            warnings.append(f"Zararli icerik: {kw}")
            health_score = max(0, health_score - 8)

    for kw in HEALTHY_KEYWORDS:
        if kw in ing:
            positives.append(f"Saglikli icerik: {kw}")
            health_score = min(100, health_score + 3)

    # Kapsamli Diyet Kontrolu
    if req.user_diet and req.user_diet != '':
        ing_lower = (req.ingredients or '').lower()
        
        diet_ingredient_rules = {
            'Vegan': [
                ('et', 'Et iceriyor - Vegan diyete uygun degil!'),
                ('meat', 'Et iceriyor - Vegan diyete uygun degil!'),
                ('tavuk', 'Tavuk iceriyor - Vegan diyete uygun degil!'),
                ('chicken', 'Tavuk iceriyor - Vegan diyete uygun degil!'),
                ('balik', 'Balik iceriyor - Vegan diyete uygun degil!'),
                ('fish', 'Balik iceriyor - Vegan diyete uygun degil!'),
                ('sut', 'Sut urunleri iceriyor - Vegan diyete uygun degil!'),
                ('milk', 'Sut urunleri iceriyor - Vegan diyete uygun degil!'),
                ('yumurta', 'Yumurta iceriyor - Vegan diyete uygun degil!'),
                ('egg', 'Yumurta iceriyor - Vegan diyete uygun degil!'),
                ('bal', 'Bal iceriyor - Vegan diyete uygun degil!'),
                ('honey', 'Bal iceriyor - Vegan diyete uygun degil!'),
                ('jelatin', 'Jelatin iceriyor - Vegan diyete uygun degil!'),
                ('gelatin', 'Jelatin iceriyor - Vegan diyete uygun degil!'),
            ],
            'Vejetaryen': [
                ('et', 'Et iceriyor - Vejetaryen diyete uygun degil!'),
                ('meat', 'Et iceriyor - Vejetaryen diyete uygun degil!'),
                ('tavuk', 'Tavuk iceriyor - Vejetaryen diyete uygun degil!'),
                ('chicken', 'Tavuk iceriyor - Vejetaryen diyete uygun degil!'),
                ('balik', 'Balik iceriyor - Vejetaryen diyete uygun degil!'),
                ('fish', 'Balik iceriyor - Vejetaryen diyete uygun degil!'),
                ('jelatin', 'Jelatin iceriyor - Vejetaryen diyete uygun degil!'),
                ('gelatin', 'Jelatin iceriyor - Vejetaryen diyete uygun degil!'),
            ],
            'Glutensiz': [
                ('bugday', 'Bugday iceriyor - Glutensiz diyete uygun degil!'),
                ('wheat', 'Bugday iceriyor - Glutensiz diyete uygun degil!'),
                ('gluten', 'Gluten iceriyor - Glutensiz diyete uygun degil!'),
                ('arpa', 'Arpa iceriyor - Glutensiz diyete uygun degil!'),
                ('barley', 'Arpa iceriyor - Glutensiz diyete uygun degil!'),
                ('cavdar', 'Cavdar iceriyor - Glutensiz diyete uygun degil!'),
                ('rye', 'Cavdar iceriyor - Glutensiz diyete uygun degil!'),
                ('irmik', 'Irmik iceriyor - Glutensiz diyete uygun degil!'),
            ],
            'Keto': [
                ('seker', 'Seker iceriyor - Keto diyete uygun degil!'),
                ('sugar', 'Seker iceriyor - Keto diyete uygun degil!'),
                ('nisasta', 'Nisasta iceriyor - Keto diyete uygun degil!'),
                ('starch', 'Nisasta iceriyor - Keto diyete uygun degil!'),
                ('glikoz surubu', 'Glikoz surubu iceriyor - Keto diyete uygun degil!'),
                ('corn syrup', 'Misir surubu iceriyor - Keto diyete uygun degil!'),
            ],
        }

        nutrient_rules = {
            'Kas Kazan': [
                (req.protein_100g < 10, 'Dusuk protein ({}g/100g) - Kas kazanimi icin yetersiz!'.format(req.protein_100g), 10),
                (req.sugar_100g > 20, 'Yuksek seker ({}g/100g) - Kas kazanimi icin ideal degil!'.format(req.sugar_100g), 8),
            ],
            'Saglikli Kal': [
                (req.sugar_100g > 15, 'Yuksek seker ({}g/100g) - Saglikli beslenme icin fazla!'.format(req.sugar_100g), 8),
                (req.salt_100g > 1.5, 'Yuksek tuz ({}g/100g) - Saglikli beslenme icin dikkat!'.format(req.salt_100g), 5),
                (req.fat_100g > 20, 'Yuksek yag ({}g/100g) - Saglikli beslenme icin fazla!'.format(req.fat_100g), 5),
            ],
            'Enerji Artir': [
                (req.energy_100g < 100, 'Dusuk kalori ({} kcal) - Enerji artisi icin yetersiz!'.format(req.energy_100g), 5),
                (req.protein_100g < 5, 'Dusuk protein ({}g/100g) - Enerji icin yetersiz!'.format(req.protein_100g), 5),
            ],
            'Sporcu': [
                (req.sugar_100g > 15, 'Yuksek seker ({}g/100g) - Sporcu performansi icin ideal degil!'.format(req.sugar_100g), 10),
                (req.protein_100g < 5, 'Dusuk protein ({}g/100g) - Sporcu icin yetersiz protein!'.format(req.protein_100g), 5),
                (req.fat_100g > 25, 'Yuksek yag ({}g/100g) - Sporcu beslenmesi icin fazla!'.format(req.fat_100g), 8),
                (req.salt_100g > 2, 'Cok yuksek tuz ({}g/100g) - Sporcu icin dikkat!'.format(req.salt_100g), 5),
            ],
            'Diyabet': [
                (req.sugar_100g > 5, 'Yuksek seker ({}g/100g) - Kan seker dengesini bozabilir!'.format(req.sugar_100g), 20),
                (req.energy_100g > 400, 'Yuksek kalori ({} kcal) - Kilo kontrolu zorlasiyor!'.format(req.energy_100g), 5),
            ],
            'Kalp Sagligi': [
                (req.salt_100g > 1.5, 'Yuksek tuz ({}g/100g) - Tansiyon ve kalp sagligi icin zararli!'.format(req.salt_100g), 15),
                (req.fat_100g > 20, 'Yuksek yag ({}g/100g) - Kalp sagligi icin dikkat!'.format(req.fat_100g), 10),
                (req.sugar_100g > 20, 'Yuksek seker ({}g/100g) - Kalp sagligi icin dikkat!'.format(req.sugar_100g), 8),
            ],
            'Dusuk Kalori': [
                (req.energy_100g > 300, 'Yuksek kalori ({} kcal/100g) - Dusuk kalorili diyet icin uygun degil!'.format(req.energy_100g), 15),
                (req.fat_100g > 15, 'Yuksek yag ({}g/100g) - Kalori kontrolu icin dikkat!'.format(req.fat_100g), 8),
                (req.sugar_100g > 10, 'Yuksek seker ({}g/100g) - Gereksiz kalori ekler!'.format(req.sugar_100g), 5),
            ],
            'Keto': [
                (req.sugar_100g > 5, 'Yuksek seker ({}g/100g) - Keto diyetinde seker cok dusuk olmali!'.format(req.sugar_100g), 15),
            ],
        }

        import re as re2
        def word_check(text, kw):
            # Kelimeyi bosluk, virgul, parantez ile sinirla
            padded = ' ' + text.replace(',', ' ').replace('(', ' ').replace(')', ' ') + ' '
            return (' ' + kw + ' ') in padded

        diet_warning_added = False

        # Icerik bazli kontrol
        if req.user_diet in diet_ingredient_rules:
            for keyword, msg in diet_ingredient_rules[req.user_diet]:
                if word_check(ing_lower, keyword):
                    warnings.append('⚠️ ' + msg)
                    health_score = max(0, health_score - 25)
                    diet_warning_added = True
                    break

        # Besin degeri bazli kontrol
        if req.user_diet in nutrient_rules:
            for condition, msg, penalty in nutrient_rules[req.user_diet]:
                if condition:
                    warnings.append('⚠️ ' + msg)
                    health_score = max(0, health_score - penalty)
                    diet_warning_added = True

        # Diyete uygunsa pozitif mesaj
        if not diet_warning_added:
            positives.append('✅ ' + req.user_diet + ' diyetine uygun gorunuyor!')

    # Alerjen kontrolu
    for ua in (req.user_allergens or []):
        for pa in (req.allergens or []):
            if ua.lower() in pa.lower():
                allergen_warnings.append(f"UYARI: {pa} alerjininiz var!")
                health_score = max(0, health_score - 20)

    # Skoru sabitle ve kategoriyi guncelle
    health_score = max(0, min(100, health_score))
    if health_score >= 65:
        category = 'healthy'
    elif health_score >= 40:
        category = 'medium'
    else:
        category = 'unhealthy'

    # Oneriler
    if health_score >= 65:
        suggestions.append("Saglikli bir secim!")
        suggestions.append("Dengeli beslenmenin parcasi olabilir")
    elif health_score >= 40:
        suggestions.append("Arasiria tuketilebilir, porsiyona dikkat edin")
        suggestions.append("Daha saglikli alternatifler tercih edilebilir")
    else:
        suggestions.append("Bu urunu tuketime dikkat edin!")
        suggestions.append("Daha saglikli alternatifleri tercih edin")

    if detected_additives:
        high_risk = [a for a in detected_additives if a['risk'] == 'yuksek']
        if high_risk:
            suggestions.append(f"{len(high_risk)} yuksek riskli katki maddesi tespit edildi!")

    if allergen_warnings:
        suggestions.append("Bu urun alerjininize uygun degil!")

    category_labels = {
        'healthy': 'Saglikli',
        'medium': 'Orta',
        'unhealthy': 'Sagliksiz'
    }

    summary = f"{req.name} analiz edildi. Saglik skoru: {health_score}/100. "
    if detected_additives:
        summary += f"{len(detected_additives)} katki maddesi tespit edildi. "
    if allergen_warnings:
        summary += "ALERJEN UYARISI! "
    summary += category_labels.get(category, '')

    return AnalyzeResponse(
        health_score=health_score,
        category=category,
        category_label=category_labels.get(category, category),
        warnings=warnings,
        positives=positives,
        suggestions=suggestions,
        detected_additives=detected_additives,
        allergen_warnings=allergen_warnings,
        summary=summary,
    )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
