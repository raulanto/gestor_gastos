import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

class AppDatabase {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gestor_gastos.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL
      )
    ''');
    
    // Tabla de Cuentas
    await db.execute('''
      CREATE TABLE accounts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        balance REAL NOT NULL DEFAULT 0.0,
        icon_code INTEGER NOT NULL,
        color_code INTEGER NOT NULL
      )
    ''');

    // Tabla de Categorías
    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_code INTEGER NOT NULL,
        color_code INTEGER NOT NULL,
        parent_id INTEGER,
        FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Transacciones (Gastos, Ingresos, Transferencias)
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        account_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        receipt_path TEXT,
        type TEXT NOT NULL,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Transaction Splits (para dividir un gasto en varias categorías)
    await db.execute('''
      CREATE TABLE transaction_splits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // PRE-CARGA DE DATOS POR DEFECTO

    // 1. Cuentas Base
    await db.insert('accounts', {'name': 'Efectivo', 'balance': 0.0, 'icon_code': Icons.money.codePoint, 'color_code': Colors.green.toARGB32()});
    await db.insert('accounts', {'name': 'Cuenta Bancaria', 'balance': 0.0, 'icon_code': Icons.account_balance.codePoint, 'color_code': Colors.blue.toARGB32()});
    await db.insert('accounts', {'name': 'Tarjeta de Crédito', 'balance': 0.0, 'icon_code': Icons.credit_card.codePoint, 'color_code': Colors.orange.toARGB32()});

    // 2. Categorías Base
    // Comida
    final comidaId = await db.insert('categories', {'name': 'Comida', 'icon_code': Icons.restaurant.codePoint, 'color_code': Colors.redAccent.toARGB32()});
    await db.insert('categories', {'name': 'Súper', 'icon_code': Icons.shopping_cart.codePoint, 'color_code': Colors.redAccent.toARGB32(), 'parent_id': comidaId});
    await db.insert('categories', {'name': 'Restaurantes', 'icon_code': Icons.fastfood.codePoint, 'color_code': Colors.redAccent.toARGB32(), 'parent_id': comidaId});

    // Transporte
    final transporteId = await db.insert('categories', {'name': 'Transporte', 'icon_code': Icons.directions_car.codePoint, 'color_code': Colors.blueAccent.toARGB32()});
    await db.insert('categories', {'name': 'Gasolina', 'icon_code': Icons.local_gas_station.codePoint, 'color_code': Colors.blueAccent.toARGB32(), 'parent_id': transporteId});
    await db.insert('categories', {'name': 'Público', 'icon_code': Icons.directions_bus.codePoint, 'color_code': Colors.blueAccent.toARGB32(), 'parent_id': transporteId});

    // Vivienda
    final viviendaId = await db.insert('categories', {'name': 'Vivienda', 'icon_code': Icons.home.codePoint, 'color_code': Colors.teal.toARGB32()});
    await db.insert('categories', {'name': 'Renta/Hipoteca', 'icon_code': Icons.house.codePoint, 'color_code': Colors.teal.toARGB32(), 'parent_id': viviendaId});
    await db.insert('categories', {'name': 'Servicios', 'icon_code': Icons.bolt.codePoint, 'color_code': Colors.teal.toARGB32(), 'parent_id': viviendaId});

    // Entretenimiento
    final ocioId = await db.insert('categories', {'name': 'Entretenimiento', 'icon_code': Icons.movie.codePoint, 'color_code': Colors.purple.toARGB32()});
    await db.insert('categories', {'name': 'Suscripciones', 'icon_code': Icons.subscriptions.codePoint, 'color_code': Colors.purple.toARGB32(), 'parent_id': ocioId});
    await db.insert('categories', {'name': 'Salidas', 'icon_code': Icons.nightlife.codePoint, 'color_code': Colors.purple.toARGB32(), 'parent_id': ocioId});
  }
}
