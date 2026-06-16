import pandas as pd
import numpy as np
from sklearn.ensemble import GradientBoostingRegressor, RandomForestClassifier, VotingClassifier
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score, mean_squared_error, r2_score
import joblib
import json
import requests
import warnings
warnings.filterwarnings('ignore')

# ============================================
# 1. GERÇEK VERİ İNDİR (Open Food Facts)
# ============================================

def download_real_data():
    """Open Food Facts'ten gerçek ürün verisi indir"""
    print("Gercek veri indiriliyor...")
    
    real_products = []
    
    # Bilinen ürünlerin barkodları
    barcodes = [
        # Sagliksiz
        '5449000000996',  # Coca Cola
        '3017620422003',  # Nutella
        '5053990108812',  # Pringles
        '7613035518209',  # Kit Kat
        '4005500131304',  # Haribo
        '8000500310427',  # Kinder Bueno
        '7622210449283',  # Oreo
        '5000159484695',  # Cadbury
        '4251097500098',  # Chips
        '5010477348735',  # Fanta
        # Orta
        '3228857000166',  # Activia yogurt
        '7613032655495',  # Nestle cereals
        '3033710065967',  # Evian water
        '5449000214911',  # Sprite
        '4056489290148',  # Bread
        # Saglikli
        '3560070976522',  # Whole grain
        '3270190122305',  # Lentils
        '3560070150515',  # Oats
        '3017620424403',  # Fruit
        '3228021290011',  # Yogurt nature
    ]
    
    for barcode in barcodes:
        try:
            url = f"https://world.openfoodfacts.org/api/v0/product/{barcode}.json"
            r = requests.get(url, timeout=5)
            if r.status_code == 200:
                data = r.json()
                if data.get('status') == 1:
                    p = data['product']
                    n = p.get('nutriments', {})
                    real_products.append({
                        'name': p.get('product_name', 'Unknown'),
                        'sugar_100g': float(n.get('sugars_100g', 0) or 0),
                        'fat_100g': float(n.get('fat_100g', 0) or 0),
                        'salt_100g': float(n.get('salt_100g', 0) or 0),
                        'protein_100g': float(n.get('proteins_100g', 0) or 0),
                        'fiber_100g': float(n.get('fiber_100g', 0) or 0),
                        'energy_100g': float(n.get('energy-kcal_100g', 0) or 0),
                        'ingredients': p.get('ingredients_text', ''),
                        'nutriscore': p.get('nutriscore_grade', ''),
                        'nova_group': int(p.get('nova_group', 4) or 4),
                        'allergens': p.get('allergens_tags', []),
                    })
                    print(f"  ✅ {p.get('product_name', barcode)}")
        except Exception as e:
            print(f"  ❌ {barcode}: {e}")
    
    print(f"\nIndirilen urun: {len(real_products)}")
    return real_products

# ============================================
# 2. KAPSAMLI EĞİTİM VERİSİ
# ============================================

def create_comprehensive_data():
    """Kapsamlı ve gerçekçi eğitim verisi"""
    
    products = [
        # ========== ÇOKTA SAĞLIKSIZ (0-25) ==========
        {
            'name': 'Gazli Icecek (Cola)', 'sugar_100g': 10.6, 'fat_100g': 0.0,
            'salt_100g': 0.01, 'protein_100g': 0.0, 'fiber_100g': 0.0,
            'energy_100g': 42, 'nova_group': 4,
            'has_high_risk_additives': 2,  # e150d, e338
            'has_medium_risk_additives': 1,  # e330
            'has_low_risk_additives': 0,
            'has_artificial_sweetener': 0, 'has_artificial_color': 1,
            'has_preservative': 0, 'allergen_count': 0,
            'is_processed': 1, 'health_score': 22
        },
        {
            'name': 'Cips (Patates)', 'sugar_100g': 0.5, 'fat_100g': 35.0,
            'salt_100g': 2.2, 'protein_100g': 6.5, 'fiber_100g': 3.4,
            'energy_100g': 536, 'nova_group': 4,
            'has_high_risk_additives': 2, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 1, 'has_preservative': 1,
            'allergen_count': 1, 'is_processed': 1, 'health_score': 18
        },
        {
            'name': 'Nutella', 'sugar_100g': 56.3, 'fat_100g': 30.9,
            'salt_100g': 0.107, 'protein_100g': 6.3, 'fiber_100g': 0.0,
            'energy_100g': 539, 'nova_group': 4,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 2, 'is_processed': 1, 'health_score': 20
        },
        {
            'name': 'Islenmis Et (Salam)', 'sugar_100g': 1.0, 'fat_100g': 28.0,
            'salt_100g': 3.5, 'protein_100g': 14.0, 'fiber_100g': 0.0,
            'energy_100g': 320, 'nova_group': 4,
            'has_high_risk_additives': 2, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 1, 'is_processed': 1, 'health_score': 15
        },
        {
            'name': 'Sekerleme', 'sugar_100g': 78.0, 'fat_100g': 2.0,
            'salt_100g': 0.1, 'protein_100g': 4.0, 'fiber_100g': 0.0,
            'energy_100g': 350, 'nova_group': 4,
            'has_high_risk_additives': 3, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 1,
            'has_artificial_color': 1, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 1, 'health_score': 10
        },
        {
            'name': 'Fast Food Burger', 'sugar_100g': 5.0, 'fat_100g': 18.0,
            'salt_100g': 1.8, 'protein_100g': 14.0, 'fiber_100g': 1.0,
            'energy_100g': 250, 'nova_group': 4,
            'has_high_risk_additives': 2, 'has_medium_risk_additives': 2,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 4, 'is_processed': 1, 'health_score': 20
        },
        {
            'name': 'Tatli Misir Gevregi', 'sugar_100g': 35.0, 'fat_100g': 2.0,
            'salt_100g': 0.8, 'protein_100g': 6.0, 'fiber_100g': 3.0,
            'energy_100g': 380, 'nova_group': 4,
            'has_high_risk_additives': 1, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 1, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 1, 'health_score': 25
        },
        {
            'name': 'Hazir Noodle', 'sugar_100g': 2.0, 'fat_100g': 15.0,
            'salt_100g': 4.5, 'protein_100g': 8.0, 'fiber_100g': 1.0,
            'energy_100g': 450, 'nova_group': 4,
            'has_high_risk_additives': 1, 'has_medium_risk_additives': 2,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 2, 'is_processed': 1, 'health_score': 18
        },
        
        # ========== SAĞLIKSIZ (25-45) ==========
        {
            'name': 'Cikolata Bar', 'sugar_100g': 52.0, 'fat_100g': 30.0,
            'salt_100g': 0.3, 'protein_100g': 5.0, 'fiber_100g': 2.5,
            'energy_100g': 510, 'nova_group': 4,
            'has_high_risk_additives': 1, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 3, 'is_processed': 1, 'health_score': 30
        },
        {
            'name': 'Beyaz Ekmek', 'sugar_100g': 4.0, 'fat_100g': 3.0,
            'salt_100g': 1.1, 'protein_100g': 8.0, 'fiber_100g': 2.0,
            'energy_100g': 265, 'nova_group': 3,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 1, 'is_processed': 1, 'health_score': 40
        },
        {
            'name': 'Meyve Suyu (Kutulu)', 'sugar_100g': 22.0, 'fat_100g': 0.0,
            'salt_100g': 0.05, 'protein_100g': 0.3, 'fiber_100g': 0.2,
            'energy_100g': 90, 'nova_group': 3,
            'has_high_risk_additives': 1, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 1, 'has_preservative': 1,
            'allergen_count': 0, 'is_processed': 1, 'health_score': 35
        },
        {
            'name': 'Dondurulmus Pizza', 'sugar_100g': 4.0, 'fat_100g': 12.0,
            'salt_100g': 1.5, 'protein_100g': 10.0, 'fiber_100g': 2.0,
            'energy_100g': 250, 'nova_group': 4,
            'has_high_risk_additives': 1, 'has_medium_risk_additives': 2,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 4, 'is_processed': 1, 'health_score': 32
        },

        # ========== ORTA (45-65) ==========
        {
            'name': 'Yogurt (Sade)', 'sugar_100g': 4.7, 'fat_100g': 3.5,
            'salt_100g': 0.1, 'protein_100g': 4.5, 'fiber_100g': 0.0,
            'energy_100g': 65, 'nova_group': 2,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 65
        },
        {
            'name': 'Sut', 'sugar_100g': 4.8, 'fat_100g': 3.5,
            'salt_100g': 0.1, 'protein_100g': 3.4, 'fiber_100g': 0.0,
            'energy_100g': 65, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 68
        },
        {
            'name': 'Peynir (Beyaz)', 'sugar_100g': 0.5, 'fat_100g': 20.0,
            'salt_100g': 1.5, 'protein_100g': 18.0, 'fiber_100g': 0.0,
            'energy_100g': 260, 'nova_group': 2,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 58
        },
        {
            'name': 'Tam Bugday Ekmek', 'sugar_100g': 3.5, 'fat_100g': 2.5,
            'salt_100g': 0.8, 'protein_100g': 9.0, 'fiber_100g': 6.5,
            'energy_100g': 240, 'nova_group': 3,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 1, 'is_processed': 1, 'health_score': 62
        },
        {
            'name': 'Yumurta', 'sugar_100g': 0.4, 'fat_100g': 10.0,
            'salt_100g': 0.3, 'protein_100g': 13.0, 'fiber_100g': 0.0,
            'energy_100g': 155, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 72
        },
        {
            'name': 'Zeytin', 'sugar_100g': 0.5, 'fat_100g': 15.0,
            'salt_100g': 2.0, 'protein_100g': 1.0, 'fiber_100g': 3.5,
            'energy_100g': 145, 'nova_group': 2,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 60
        },

        # ========== SAĞLIKLI (65-85) ==========
        {
            'name': 'Yulaf Ezmesi', 'sugar_100g': 1.1, 'fat_100g': 6.9,
            'salt_100g': 0.01, 'protein_100g': 13.5, 'fiber_100g': 10.1,
            'energy_100g': 389, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 88
        },
        {
            'name': 'Tavuk Gogsu', 'sugar_100g': 0.0, 'fat_100g': 3.6,
            'salt_100g': 0.08, 'protein_100g': 31.0, 'fiber_100g': 0.0,
            'energy_100g': 165, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 85
        },
        {
            'name': 'Badem', 'sugar_100g': 4.4, 'fat_100g': 49.9,
            'salt_100g': 0.0, 'protein_100g': 21.2, 'fiber_100g': 12.5,
            'energy_100g': 579, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 82
        },
        {
            'name': 'Mercimek', 'sugar_100g': 2.0, 'fat_100g': 1.1,
            'salt_100g': 0.01, 'protein_100g': 25.0, 'fiber_100g': 15.0,
            'energy_100g': 352, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 90
        },
        {
            'name': 'Somon Baligi', 'sugar_100g': 0.0, 'fat_100g': 13.0,
            'salt_100g': 0.1, 'protein_100g': 25.0, 'fiber_100g': 0.0,
            'energy_100g': 208, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 86
        },
        {
            'name': 'Brokoli', 'sugar_100g': 1.7, 'fat_100g': 0.4,
            'salt_100g': 0.04, 'protein_100g': 2.8, 'fiber_100g': 2.6,
            'energy_100g': 34, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 95
        },
        {
            'name': 'Ispanak', 'sugar_100g': 0.4, 'fat_100g': 0.4,
            'salt_100g': 0.08, 'protein_100g': 2.9, 'fiber_100g': 2.2,
            'energy_100g': 23, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 95
        },
        {
            'name': 'Elma', 'sugar_100g': 10.0, 'fat_100g': 0.2,
            'salt_100g': 0.0, 'protein_100g': 0.3, 'fiber_100g': 2.4,
            'energy_100g': 52, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 92
        },
        {
            'name': 'Zeytinyagi', 'sugar_100g': 0.0, 'fat_100g': 100.0,
            'salt_100g': 0.0, 'protein_100g': 0.0, 'fiber_100g': 0.0,
            'energy_100g': 884, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 80
        },
        {
            'name': 'Chia Tohumu', 'sugar_100g': 0.0, 'fat_100g': 31.0,
            'salt_100g': 0.02, 'protein_100g': 17.0, 'fiber_100g': 34.0,
            'energy_100g': 486, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 93
        },
        {
            'name': 'Kinoa', 'sugar_100g': 0.0, 'fat_100g': 6.0,
            'salt_100g': 0.01, 'protein_100g': 14.0, 'fiber_100g': 7.0,
            'energy_100g': 368, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 91
        },
        # ========== TÜRK ÜRÜNLERİ ==========
        # Eti
        {
            'name': 'Eti Cin Biskuvi', 'sugar_100g': 28.0, 'fat_100g': 18.0,
            'salt_100g': 0.8, 'protein_100g': 6.5, 'fiber_100g': 1.5,
            'energy_100g': 460, 'nova_group': 4,
            'has_high_risk_additives': 1, 'has_medium_risk_additives': 2,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 3, 'is_processed': 1, 'health_score': 28
        },
        {
            'name': 'Eti Browni', 'sugar_100g': 45.0, 'fat_100g': 22.0,
            'salt_100g': 0.5, 'protein_100g': 5.0, 'fiber_100g': 1.0,
            'energy_100g': 420, 'nova_group': 4,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 2,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 3, 'is_processed': 1, 'health_score': 22
        },
        {
            'name': 'Eti Tutku Cikolata', 'sugar_100g': 55.0, 'fat_100g': 28.0,
            'salt_100g': 0.2, 'protein_100g': 5.5, 'fiber_100g': 2.0,
            'energy_100g': 510, 'nova_group': 4,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 3, 'is_processed': 1, 'health_score': 20
        },
        # Ülker
        {
            'name': 'Ulker Cikolata', 'sugar_100g': 52.0, 'fat_100g': 30.0,
            'salt_100g': 0.15, 'protein_100g': 6.0, 'fiber_100g': 2.5,
            'energy_100g': 520, 'nova_group': 4,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 3, 'is_processed': 1, 'health_score': 22
        },
        {
            'name': 'Ulker Biskuvi', 'sugar_100g': 22.0, 'fat_100g': 16.0,
            'salt_100g': 0.7, 'protein_100g': 7.0, 'fiber_100g': 2.0,
            'energy_100g': 450, 'nova_group': 4,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 2, 'is_processed': 1, 'health_score': 32
        },
        {
            'name': 'Ulker Hanımeller', 'sugar_100g': 30.0, 'fat_100g': 20.0,
            'salt_100g': 0.6, 'protein_100g': 6.0, 'fiber_100g': 1.5,
            'energy_100g': 480, 'nova_group': 4,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 2, 'is_processed': 1, 'health_score': 28
        },
        # Sutaş / Pınar
        {
            'name': 'Sutas Sut', 'sugar_100g': 4.8, 'fat_100g': 3.6,
            'salt_100g': 0.1, 'protein_100g': 3.4, 'fiber_100g': 0.0,
            'energy_100g': 66, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 70
        },
        {
            'name': 'Sutas Yogurt', 'sugar_100g': 4.5, 'fat_100g': 3.8,
            'salt_100g': 0.1, 'protein_100g': 4.5, 'fiber_100g': 0.0,
            'energy_100g': 68, 'nova_group': 2,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 72
        },
        {
            'name': 'Pinar Kasar Peynir', 'sugar_100g': 0.1, 'fat_100g': 26.0,
            'salt_100g': 1.8, 'protein_100g': 26.0, 'fiber_100g': 0.0,
            'energy_100g': 350, 'nova_group': 2,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 65
        },
        {
            'name': 'Pinar Ayran', 'sugar_100g': 3.5, 'fat_100g': 1.5,
            'salt_100g': 0.5, 'protein_100g': 3.0, 'fiber_100g': 0.0,
            'energy_100g': 42, 'nova_group': 2,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 68
        },
        # Torku / Koska
        {
            'name': 'Torku Findik Kremasi', 'sugar_100g': 50.0, 'fat_100g': 32.0,
            'salt_100g': 0.1, 'protein_100g': 7.0, 'fiber_100g': 1.5,
            'energy_100g': 545, 'nova_group': 4,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 1,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 2, 'is_processed': 1, 'health_score': 22
        },
        {
            'name': 'Koska Helva', 'sugar_100g': 38.0, 'fat_100g': 30.0,
            'salt_100g': 0.2, 'protein_100g': 12.0, 'fiber_100g': 3.0,
            'energy_100g': 520, 'nova_group': 3,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 2, 'is_processed': 1, 'health_score': 42
        },
        # Hazır yemekler
        {
            'name': 'Konserve Domates', 'sugar_100g': 3.5, 'fat_100g': 0.3,
            'salt_100g': 0.8, 'protein_100g': 1.5, 'fiber_100g': 1.5,
            'energy_100g': 32, 'nova_group': 2,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 1, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 1, 'health_score': 62
        },
        {
            'name': 'Hazir Corbа', 'sugar_100g': 8.0, 'fat_100g': 5.0,
            'salt_100g': 5.5, 'protein_100g': 5.0, 'fiber_100g': 1.0,
            'energy_100g': 350, 'nova_group': 4,
            'has_high_risk_additives': 1, 'has_medium_risk_additives': 2,
            'has_low_risk_additives': 2, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 1,
            'allergen_count': 2, 'is_processed': 1, 'health_score': 20
        },
        {
            'name': 'Turk Kahvesi', 'sugar_100g': 0.0, 'fat_100g': 0.0,
            'salt_100g': 0.0, 'protein_100g': 0.0, 'fiber_100g': 0.0,
            'energy_100g': 2, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 78
        },
        {
            'name': 'Cay (Demlik)', 'sugar_100g': 0.0, 'fat_100g': 0.0,
            'salt_100g': 0.0, 'protein_100g': 0.2, 'fiber_100g': 0.0,
            'energy_100g': 1, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 82
        },
        {
            'name': 'Bulgur', 'sugar_100g': 0.4, 'fat_100g': 1.3,
            'salt_100g': 0.02, 'protein_100g': 12.3, 'fiber_100g': 18.3,
            'energy_100g': 342, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 88
        },
        {
            'name': 'Nohut', 'sugar_100g': 10.7, 'fat_100g': 6.0,
            'salt_100g': 0.02, 'protein_100g': 19.3, 'fiber_100g': 17.4,
            'energy_100g': 364, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 0, 'is_processed': 0, 'health_score': 87
        },
        {
            'name': 'Tahin', 'sugar_100g': 0.3, 'fat_100g': 53.0,
            'salt_100g': 0.02, 'protein_100g': 17.0, 'fiber_100g': 9.3,
            'energy_100g': 595, 'nova_group': 1,
            'has_high_risk_additives': 0, 'has_medium_risk_additives': 0,
            'has_low_risk_additives': 0, 'has_artificial_sweetener': 0,
            'has_artificial_color': 0, 'has_preservative': 0,
            'allergen_count': 1, 'is_processed': 0, 'health_score': 83
        },
    ]
    
    return pd.DataFrame(products)


# ============================================
# 3. FEATURE MÜHENDİSLİĞİ
# ============================================

def engineer_features(df):
    """Ek özellikler türet"""
    
    # Şeker/protein oranı
    df['sugar_protein_ratio'] = df['sugar_100g'] / (df['protein_100g'] + 1)
    
    # Yağ/protein oranı
    df['fat_protein_ratio'] = df['fat_100g'] / (df['protein_100g'] + 1)
    
    # Toplam kötü katkı
    df['total_bad_additives'] = (
        df['has_high_risk_additives'] * 3 +
        df['has_medium_risk_additives'] * 2 +
        df['has_low_risk_additives']
    )
    
    # Besin yoğunluğu skoru
    df['nutrient_density'] = (
        df['protein_100g'] * 2 +
        df['fiber_100g'] * 2 -
        df['sugar_100g'] * 1.5 -
        df['salt_100g'] * 10
    )
    
    # İşlenme cezası
    df['processing_penalty'] = df['nova_group'] * 5
    
    return df


# ============================================
# 4. MODELİ EĞİT
# ============================================

def train_and_save():
    print("=" * 50)
    print("FoodsenseAI - ML Model Egitimi")
    print("=" * 50)
    
    # Veri oluştur
    df = create_comprehensive_data()
    df = engineer_features(df)
    print(f"Toplam ornek: {len(df)}")
    
    # Augmentation - veriyi çoğalt
    augmented = []
    for _, row in df.iterrows():
        for _ in range(30):
            new_row = row.copy()
            new_row['sugar_100g'] = max(0, row['sugar_100g'] + np.random.normal(0, 0.5))
            new_row['fat_100g'] = max(0, row['fat_100g'] + np.random.normal(0, 1))
            new_row['salt_100g'] = max(0, row['salt_100g'] + np.random.normal(0, 0.05))
            new_row['protein_100g'] = max(0, row['protein_100g'] + np.random.normal(0, 0.5))
            new_row['fiber_100g'] = max(0, row['fiber_100g'] + np.random.normal(0, 0.2))
            new_row['health_score'] = min(100, max(0, row['health_score'] + np.random.randint(-3, 4)))
            # Feature'ları yeniden hesapla
            new_row['sugar_protein_ratio'] = new_row['sugar_100g'] / (new_row['protein_100g'] + 1)
            new_row['fat_protein_ratio'] = new_row['fat_100g'] / (new_row['protein_100g'] + 1)
            new_row['nutrient_density'] = (
                new_row['protein_100g'] * 2 + new_row['fiber_100g'] * 2 -
                new_row['sugar_100g'] * 1.5 - new_row['salt_100g'] * 10
            )
            augmented.append(new_row)
    
    df_aug = pd.DataFrame(augmented)
    print(f"Augmentation sonrasi: {len(df_aug)} ornek")
    
    # Features
    feature_cols = [
        'sugar_100g', 'fat_100g', 'salt_100g', 'protein_100g',
        'fiber_100g', 'energy_100g', 'nova_group',
        'has_high_risk_additives', 'has_medium_risk_additives',
        'has_low_risk_additives', 'has_artificial_sweetener',
        'has_artificial_color', 'has_preservative',
        'allergen_count', 'is_processed',
        'sugar_protein_ratio', 'fat_protein_ratio',
        'total_bad_additives', 'nutrient_density', 'processing_penalty'
    ]
    
    X = df_aug[feature_cols]
    y = df_aug['health_score']
    
    # Kategori
    def score_to_category(s):
        if s >= 65: return 'healthy'
        elif s >= 40: return 'medium'
        else: return 'unhealthy'
    
    y_cat = y.apply(score_to_category)
    
    # Split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    X_train_c, X_test_c, y_train_c, y_test_c = train_test_split(X, y_cat, test_size=0.2, random_state=42)
    
    # Scale
    scaler = StandardScaler()
    X_train_s = scaler.fit_transform(X_train)
    X_test_s = scaler.transform(X_test)
    X_train_cs = scaler.transform(X_train_c)
    X_test_cs = scaler.transform(X_test_c)
    
    # Model 1: Skor tahmini
    print("\nSkor modeli egitiliyor...")
    score_model = GradientBoostingRegressor(
        n_estimators=500,
        max_depth=5,
        learning_rate=0.05,
        subsample=0.8,
        min_samples_split=5,
        random_state=42
    )
    score_model.fit(X_train_s, y_train)
    y_pred = score_model.predict(X_test_s)
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    print(f"  RMSE: {mse**0.5:.2f}")
    print(f"  R²: {r2:.3f}")
    
    # Cross validation
    cv_scores = cross_val_score(score_model, scaler.transform(X), y, cv=5, scoring='r2')
    print(f"  CV R²: {cv_scores.mean():.3f} (+/- {cv_scores.std():.3f})")
    
    # Model 2: Kategori sınıflandırma
    print("\nKategori modeli egitiliyor...")
    cat_model = RandomForestClassifier(
        n_estimators=200,
        max_depth=8,
        min_samples_split=5,
        random_state=42
    )
    cat_model.fit(X_train_cs, y_train_c)
    y_pred_c = cat_model.predict(X_test_cs)
    acc = accuracy_score(y_test_c, y_pred_c)
    print(f"  Accuracy: {acc:.2%}")
    
    cv_acc = cross_val_score(cat_model, scaler.transform(X), y_cat, cv=5)
    print(f"  CV Accuracy: {cv_acc.mean():.2%} (+/- {cv_acc.std():.2%})")
    
    # Feature importance
    print("\nEn onemli 5 feature:")
    importances = score_model.feature_importances_
    indices = np.argsort(importances)[::-1]
    for i in range(min(5, len(feature_cols))):
        print(f"  {i+1}. {feature_cols[indices[i]]}: {importances[indices[i]]:.3f}")
    
    # Kaydet
    joblib.dump(score_model, 'health_score_model.pkl')
    joblib.dump(cat_model, 'category_model.pkl')
    joblib.dump(scaler, 'scaler.pkl')
    
    with open('features.json', 'w') as f:
        json.dump(feature_cols, f)
    
    print("\nModeller kaydedildi!")
    
    # Test: Coca Cola
    print("\n--- TEST: Coca Cola ---")
    coca_cola = np.array([[10.6, 0.0, 0.01, 0.0, 0.0, 42, 4, 2, 1, 0, 0, 1, 0, 0, 1,
                           10.6/1, 0.0/1, 2*3+1*2, 0*2+0*2-10.6*1.5-0.01*10, 4*5]])
    coca_scaled = scaler.transform(coca_cola)
    score = score_model.predict(coca_scaled)[0]
    cat = cat_model.predict(coca_scaled)[0]
    print(f"  Skor: {score:.1f}/100")
    print(f"  Kategori: {cat}")
    
    # Test: Ispanak
    print("\n--- TEST: Ispanak ---")
    ispanak = np.array([[0.4, 0.4, 0.08, 2.9, 2.2, 23, 1, 0, 0, 0, 0, 0, 0, 0, 0,
                         0.4/3.9, 0.4/3.9, 0, 2.9*2+2.2*2-0.4*1.5-0.08*10, 1*5]])
    isp_scaled = scaler.transform(ispanak)
    score2 = score_model.predict(isp_scaled)[0]
    cat2 = cat_model.predict(isp_scaled)[0]
    print(f"  Skor: {score2:.1f}/100")
    print(f"  Kategori: {cat2}")
    
    return score_model, cat_model, scaler, feature_cols

if __name__ == '__main__':
    train_and_save()