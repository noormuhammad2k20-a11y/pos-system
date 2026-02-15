<?php
require_once 'db.php';
require_once 'classes.php';

echo "Starting Full Menu Database Seeder...\n";

try {
    // 1. Full Category List
    $categories = [
        'Starters / Appetizers',
        'Salads',
        'Soups',
        'Seafood',
        'Grill / BBQ',
        'Sandwiches / Wraps',
        'Breakfast',
        'Sauces / Dips',
        'Combo Meals',
        'Snacks',
        'Vegetarian',
        'Vegan',
        'Kids Menu',
        'Specials / Chef’s Choice'
    ];
    $catIds = [];

    foreach ($categories as $cat) {
        $stmt = $pdo->prepare("SELECT id FROM categories WHERE name = ?");
        $stmt->execute([$cat]);
        $existing = $stmt->fetchColumn();

        if ($existing) {
            $catIds[$cat] = $existing;
            // echo "Category exists: $cat\n";
        } else {
            $stmt = $pdo->prepare("INSERT INTO categories (name) VALUES (?)");
            $stmt->execute([$cat]);
            $catIds[$cat] = $pdo->lastInsertId();
            echo "Category added: $cat\n";
        }
    }
    GustoCache::clear('categories');

    // 2. Full Product List with Images
    $products = [
        // Starters
        ['name' => 'Classic Tomato Bruschetta', 'price' => 8.50, 'category' => 'Starters / Appetizers', 'image' => 'uploads/products/bruschetta.png'],

        // Salads
        ['name' => 'Chicken Caesar Salad', 'price' => 12.00, 'category' => 'Salads', 'image' => 'uploads/products/caesar.png'],

        // Soups
        ['name' => 'Creamy Tomato Basil Soup', 'price' => 7.00, 'category' => 'Soups', 'image' => 'uploads/products/soup.png'],

        // Seafood
        ['name' => 'Grilled Atlantic Salmon', 'price' => 22.00, 'category' => 'Seafood', 'image' => 'uploads/products/salmon.png'],

        // Grill / BBQ
        ['name' => 'Smoky BBQ Pork Ribs', 'price' => 24.50, 'category' => 'Grill / BBQ', 'image' => 'uploads/products/ribs.png'],

        // Sandwiches
        ['name' => 'Grilled Chicken Club Sandwich', 'price' => 14.00, 'category' => 'Sandwiches / Wraps', 'image' => 'uploads/products/club_sandwich.png'],

        // Breakfast
        ['name' => 'Buttermilk Pancakes Stack', 'price' => 10.50, 'category' => 'Breakfast', 'image' => 'uploads/products/pancakes.png'],

        // Sauces
        ['name' => 'Gourmet Dip Platter', 'price' => 4.00, 'category' => 'Sauces / Dips', 'image' => 'uploads/products/dips.png'],

        // Combo Meals
        ['name' => 'All-American Burger Combo', 'price' => 16.50, 'category' => 'Combo Meals', 'image' => 'uploads/products/combo.png'],

        // Snacks
        ['name' => 'Loaded Nachos Grande', 'price' => 13.50, 'category' => 'Snacks', 'image' => 'uploads/products/nachos.png'],

        // Vegetarian
        ['name' => 'Quinoa Buddha Bowl', 'price' => 15.00, 'category' => 'Vegetarian', 'image' => 'uploads/products/buddha_bowl.png'],

        // Vegan
        ['name' => 'Plant-Based Avocado Burger', 'price' => 16.00, 'category' => 'Vegan', 'image' => 'uploads/products/vegan_burger.png'],

        // Kids
        ['name' => 'Kids Chicken Nuggets Meal', 'price' => 8.99, 'category' => 'Kids Menu', 'image' => 'uploads/products/kids_nuggets.png'],

        // Specials (Using placeholder for now due to rate limit)
        ['name' => 'Chef\'s Special Steak Frites', 'price' => 29.99, 'category' => 'Specials / Chef’s Choice', 'image' => 'https://placehold.co/150x100/1e1e1e/FFF?text=Steak+Special']
    ];

    foreach ($products as $p) {
        $catId = $catIds[$p['category']];

        // Delete existing manual entries with same name to avoid clutter
        $pdo->prepare("DELETE FROM products WHERE name = ?")->execute([$p['name']]);

        // Insert new
        $stmt = $pdo->prepare("INSERT INTO products (name, price, category_id, image, is_available) VALUES (?, ?, ?, ?, 1)");
        $stmt->execute([$p['name'], $p['price'], $catId, $p['image']]);
        echo "Product added: " . $p['name'] . "\n";
    }

    echo "Full Menu Seeding Complete!\n";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
