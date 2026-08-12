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
      version: 7,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE recurring_transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          account_id INTEGER NOT NULL,
          category_id INTEGER,
          note TEXT,
          type TEXT NOT NULL,
          periodicity TEXT NOT NULL, 
          next_execution_date TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE recurring_transaction_splits(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          recurring_transaction_id INTEGER NOT NULL,
          category_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          FOREIGN KEY (recurring_transaction_id) REFERENCES recurring_transactions(id) ON DELETE CASCADE,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
        )
      ''');
    }
    
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE savings_goals(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          target_amount REAL NOT NULL,
          deadline_date TEXT,
          icon_code INTEGER NOT NULL,
          color_code INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'active'
        )
      ''');

      await db.execute('''
        CREATE TABLE savings_transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          account_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          type TEXT NOT NULL,
          reason TEXT,
          FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE,
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE savings_rules(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          goal_id INTEGER NOT NULL,
          rule_type TEXT NOT NULL,
          value REAL NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
        )
      ''');
    }
    
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category_id INTEGER,
          savings_goal_id INTEGER,
          amount REAL NOT NULL,
          month_year TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
          FOREIGN KEY (savings_goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
        )
      ''');
    }

    if (oldVersion < 5) {
      await db.execute('ALTER TABLE savings_goals ADD COLUMN is_protected INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE savings_goals ADD COLUMN priority INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE savings_goals ADD COLUMN deduct_from_balance INTEGER NOT NULL DEFAULT 1');
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE loans(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          person_name TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL,
          account_id INTEGER NOT NULL,
          date TEXT NOT NULL,
          due_date TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'active',
          FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
        )
      ''');

      await db.execute('''
        CREATE TABLE loan_payments(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          loan_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE
        )
      ''');

      // Add "Préstamos" category if not exists
      final result = await db.query('categories', where: 'name = ?', whereArgs: ['Préstamos']);
      if (result.isEmpty) {
        await db.insert('categories', {
          'name': 'Préstamos',
          'icon_code': Icons.handshake.codePoint,
          'color_code': Colors.indigo.toARGB32()
        });
      }
    }

    if (oldVersion < 7) {
      await db.execute('''
        CREATE TABLE persons(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          phone TEXT,
          photo_path TEXT
        )
      ''');
      
      await db.execute('ALTER TABLE loans ADD COLUMN person_id INTEGER');
      await db.execute('''
        CREATE INDEX idx_loans_person_id ON loans(person_id);
      ''');
    }
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

    // Tablas de Gastos Recurrentes
    await db.execute('''
      CREATE TABLE recurring_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        account_id INTEGER NOT NULL,
        category_id INTEGER,
        note TEXT,
        type TEXT NOT NULL,
        periodicity TEXT NOT NULL, 
        next_execution_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recurring_transaction_splits(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recurring_transaction_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        FOREIGN KEY (recurring_transaction_id) REFERENCES recurring_transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // Tablas de Ahorro
    await db.execute('''
      CREATE TABLE savings_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        target_amount REAL NOT NULL,
        deadline_date TEXT,
        icon_code INTEGER NOT NULL,
        color_code INTEGER NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        is_protected INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 0,
        deduct_from_balance INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        account_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        reason TEXT,
        FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE,
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_rules(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        goal_id INTEGER NOT NULL,
        rule_type TEXT NOT NULL,
        value REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        FOREIGN KEY (goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Presupuestos
    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        savings_goal_id INTEGER,
        amount REAL NOT NULL,
        month_year TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
        FOREIGN KEY (savings_goal_id) REFERENCES savings_goals(id) ON DELETE CASCADE
      )
    ''');

    // Tabla de Personas
    await db.execute('''
      CREATE TABLE persons(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        photo_path TEXT
      )
    ''');

    // Tabla de Préstamos
    await db.execute('''
      CREATE TABLE loans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_name TEXT NOT NULL,
        person_id INTEGER,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        account_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE loan_payments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (loan_id) REFERENCES loans(id) ON DELETE CASCADE
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

    // Trabajo / Ingresos
    final trabajoId = await db.insert('categories', {'name': 'Trabajo', 'icon_code': Icons.work.codePoint, 'color_code': Colors.brown.toARGB32()});
    await db.insert('categories', {'name': 'Pago Nómina', 'icon_code': Icons.attach_money.codePoint, 'color_code': Colors.brown.toARGB32(), 'parent_id': trabajoId});
    
    // Préstamos
    await db.insert('categories', {'name': 'Préstamos', 'icon_code': Icons.handshake.codePoint, 'color_code': Colors.indigo.toARGB32()});
  }
}
