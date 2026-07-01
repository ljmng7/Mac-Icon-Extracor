import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import xml.etree.ElementTree as ET
import glob
from svg.path import parse_path
import math
import json

def get_path_bbox(d):
    path = parse_path(d)
    min_x, min_y = float('inf'), float('inf')
    max_x, max_y = float('-inf'), float('-inf')
    
    if len(path) == 0:
        return None
        
    for segment in path:
        for i in range(51):
            t = i / 50.0
            point = segment.point(t)
            if math.isnan(point.real) or math.isnan(point.imag):
                continue
            min_x = min(min_x, point.real)
            max_x = max(max_x, point.real)
            min_y = min(min_y, point.imag)
            max_y = max(max_y, point.imag)
            
    if min_x == float('inf'):
        return None
    return min_x, min_y, max_x, max_y

def process_icon_bundle(bundle_path):
    svgs = glob.glob(os.path.join(bundle_path, "Assets", "*.svg"))
    crop_results = {}
    
    for svg_file in svgs:
        tree = ET.parse(svg_file)
        root = tree.getroot()
        
        ns = {"svg": "http://www.w3.org/2000/svg"}
        paths = root.findall(".//svg:path", ns)
        if not paths:
            paths = root.findall(".//path")
            
        g_min_x, g_min_y = float('inf'), float('inf')
        g_max_x, g_max_y = float('-inf'), float('-inf')
        
        for p in paths:
            d = p.get('d')
            if d:
                bbox = get_path_bbox(d)
                if bbox:
                    g_min_x = min(g_min_x, bbox[0])
                    g_min_y = min(g_min_y, bbox[1])
                    g_max_x = max(g_max_x, bbox[2])
                    g_max_y = max(g_max_y, bbox[3])
        
        if g_min_x != float('inf'):
            width = g_max_x - g_min_x
            height = g_max_y - g_min_y
            root.set('viewBox', f"{g_min_x} {g_min_y} {width} {height}")
            root.set('width', str(width))
            root.set('height', str(height))
            tree.write(svg_file)
            crop_results[os.path.basename(svg_file)] = (g_min_x, g_min_y, width, height)
            
    json_path = os.path.join(bundle_path, "icon.json")
    if not os.path.exists(json_path):
        return
        
    with open(json_path, 'r') as f:
        data = json.load(f)
        
    def process_layers(layers_list):
        for layer in layers_list:
            image_name = layer.get('image-name')
            if image_name and image_name in crop_results:
                min_x, min_y, width, height = crop_results[image_name]
                cx = min_x + width / 2.0
                cy = min_y + height / 2.0
                tx = cx - 512.0
                ty = cy - 512.0
                layer['position'] = {
                    'scale': 1.0,
                    'translation-in-points': [tx, ty]
                }
                
    for group in data.get('groups', []):
        process_layers(group.get('layers', []))
        
    with open(json_path, 'w') as f:
        json.dump(data, f, indent=2)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 crop_and_merge.py <path_to.icon>")
        sys.exit(1)
    process_icon_bundle(sys.argv[1])
