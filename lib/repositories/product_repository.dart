import 'dart:convert';
import 'dart:io';

import 'package:kiosk/models/categories.dart';
import 'package:kiosk/models/variation.dart';
import 'package:kiosk/service/user_services.dart';
import 'package:kiosk/utils/compress_image.dart';
import 'package:kiosk/utils/utils.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../models/product.dart';

class ProductRepository {
  final UserServices userServices;
  ProductRepository({
    required this.userServices,
  });

  /// Fetches a list of products with optional query parameters.
  ///
  /// This function sends a request to fetch a list of products, optionally
  /// including query parameters for filtering the results.
  ///
  /// Parameters:
  /// - `queryParameters` (Map<String, dynamic>?): Optional query parameters
  ///   to filter the products. For example, you might pass filters like
  ///   category, price range, etc. If not needed, you can pass null.
  ///
  /// - `nextPage` (String?): An optional parameter that can be used to
  ///   request the next page of results in case of paginated data. Pass null
  ///   if not applicable.
  ///
  /// Returns:
  /// A [Future] containing a [Map] with product data. The map typically
  /// includes a 'products' key that holds a list of product objects.
  ///
  /// Throws:
  /// If an error occurs during the data fetching process, the error is re-thrown.
  Future<Map<String, dynamic>> getProducts({
    Map<String, dynamic>? queryParameters,
    String? nextPage,
  }) async {
    try {
      // Send a request to fetch products based on the given parameters.
      Map<String, dynamic> response = await userServices.getUsersProducts(
        queryParameters,
        nextPage,
      );

      // Map the raw JSON data to a list of Products objects.
      response['products'] = (response['products'] as List<dynamic>)
          .map((e) => Products.fromJson(e))
          .toList();

      // Return the response containing the product data.
      return response;
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Checkout the selected products.
  ///
  /// This function adds products to the cart and then initiates the checkout
  /// process.
  ///
  /// Parameters:
  /// - `myCartCheckOut` (List<Map<dynamic, dynamic>>): A list of maps, where
  ///   each map represents a product to be added to the cart for checkout.
  ///   This is a required parameter.
  ///
  /// - `checkOut` (Map<String, dynamic>): Additional information required for
  ///   the checkout process, such as payment details, shipping address, etc.
  ///   This is a required parameter.
  ///
  /// Returns:
  /// A [Future] containing a [String] representing the order ID generated
  /// as a result of the checkout process.
  ///
  /// Throws:
  /// If an error occurs during the checkout process, the error is re-thrown.
  Future<String> checkOutProducts({
    required List<Map<dynamic, dynamic>> myCartCheckOUt,
    required Map<String, dynamic> checkOut,
  }) async {
    try {
      // Add the selected products to the cart.
      await userServices.addProductsToCart(myCartCheckOUt);

      // Perform the checkout process and get the order ID.
      final orderId =
          await userServices.checkOutProducts(checkOut, myCartCheckOUt);

      // Return the order ID.
      return orderId;
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Fetches a list of product categories.
  ///
  /// This function sends a request to fetch a list of product categories.
  ///
  /// Returns:
  /// A [Future] containing a [List] of [Categories] representing the product
  /// categories.
  ///
  /// Throws:
  /// If an error occurs during the data fetching process, the error is re-thrown.
  Future<List<Categories>> getUsersCategories() async {
    try {
      // Send a request to fetch product categories.
      return await userServices.getUsersProductsCategories();
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Deletes a product category by its ID.
  ///
  /// This function sends a request to delete a product category based on its ID.
  ///
  /// Parameters:
  /// - `categoryId` (int): The ID of the category to be deleted. This is a
  ///   required parameter.
  ///
  /// Returns:
  /// A [Future] containing a [bool] indicating whether the deletion was
  /// successful (true) or not (false).
  ///
  /// Throws:
  /// If an error occurs during the deletion process, the error is re-thrown.
  Future<bool> deleteCategory({
    required int categoryId,
  }) async {
    try {
      // Send a request to delete the specified category.
      return await userServices.deleteUsersCategories(categoryId);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Deletes a product by its ID.
  ///
  /// This function sends a request to delete a product based on its ID.
  ///
  /// Parameters:
  /// - `productId` (String): The ID of the product to be deleted. This is a
  ///   required parameter.
  ///
  /// Returns:
  /// A [Future] containing a [bool] indicating whether the deletion was
  /// successful (true) or not (false).
  ///
  /// Throws:
  /// If an error occurs during the deletion process, the error is re-thrown.
  Future<bool> deleteProduct({
    required String productId,
  }) async {
    try {
      // Send a request to delete the specified product.
      return await userServices.deleteUsersProduct(productId);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Adds a product variation to a product.
  ///
  /// This function adds a new variation to an existing product. It checks if the
  /// variation already exists, updates the product's variations, and calculates
  /// stock based on the variations.
  ///
  /// Parameters:
  /// - `product` (Products): The product to which the variation will be added.
  ///   This is a required parameter.
  ///
  /// - `variation` (Variation): The variation to be added to the product. This is
  ///   a required parameter.
  ///
  /// Returns:
  /// A [Future] containing a [bool] indicating whether the variation was added
  /// successfully (true) or not (false).
  ///
  /// Throws:
  /// If an error occurs during the process, the error is re-thrown.
  Future<bool> addProductVariation({
    required Products product,
    required Variation variation,
  }) async {
    try {
      // Check if the variation already exists.
      for (var i in product.productsVariation) {
        if (i["variation_value"].toString().toUpperCase() ==
            variation.variationValue.toUpperCase()) {
          // If the variation already exists, throw an error.
          throw "Variation already exists";
        }
      }

      // Add the new variation to the product's list of variations.
      product.productsVariation.add({
        "weight_quantity": product.chargeByWeight
            ? double.parse(variation.variationQuantity).toString()
            : 0.toString(),
        "quantity": product.chargeByWeight
            ? 0.toString()
            : int.parse(variation.variationQuantity).toInt().toString(),
        "variations_category": variation.variationType,
        "variation_value": variation.variationValue,
      });

      // Calculate the stock based on the variations.
      dynamic stock = 0;

      for (var element in product.productsVariation) {
        if (product.chargeByWeight) {
          stock += double.parse(element["weight_quantity"].toString());
        } else {
          stock += int.parse(element["quantity"].toString());
        }
      }

      // Update the product's stock and weight quantity based on the variations.
      if (product.chargeByWeight) {
        product.weightQuantity = stock.toString();
        product.stock = 0.toString();
      } else {
        product.weightQuantity = 0.toString();
        product.stock = stock.toString();
      }

      // Prepare the fields for updating the product.
      Map<String, String> fields = {
        "product_sku": product.productSku,
        "stock": product.stock,
        "charge_by_weight": json.encode(product.chargeByWeight),
        "product_name": product.productName,
        "category": product.category,
        "cost_price": product.costPrice,
        "weight_quantity": product.weightQuantity,
        "image": product.image,
        "price": product.price,
        "out_of_stock_notify": json.encode(product.outOfStockNotify),
        "low_stock_limit": product.lowStockLimit,
        "weight_unit": product.weightUnit,
        "expire_notify": jsonEncode(
            product.expireDate != null && product.expireDate!.isNotEmpty),
        "expiring_date": product.expireDate ?? "",
        "expiry_days_notify": jsonEncode(product.notificationPeriod ?? 0),
      };

      // Add the product variations to the fields for the update.
      if (product.productsVariation.isEmpty) {
        // If there are no variations, set default values for one variation.
        fields.addAll({
          "products_variation[0].variations_category": "none",
          "products_variation[0].variation_value": "none",
          "products_variation[0].weight_quantity": "none",
          "products_variation[0].quantity": "none",
        });
      } else {
        // If there are variations, add them to the fields.
        int i = 0;

        for (var element in product.productsVariation) {
          fields.addAll({
            "products_variation[$i]variations_category":
                element["variations_category"],
            "products_variation[$i]variation_value": element["variation_value"],
            "products_variation[$i]weight_quantity":
                element["weight_quantity"].toString(),
            "products_variation[$i]quantity": element["quantity"].toString(),
          });
          i++;
        }
      }

      // Call the service to edit the product with the updated fields.
      return await userServices.editProduct(fields, product.id, []);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Edits an existing product with updated information.
  ///
  /// This function sends a request to update an existing product with new
  /// information. It allows updating various properties of the product
  /// including SKU, stock, product name, category, cost price, weight quantity,
  /// price, and more. It also supports updating product variations and product
  /// images.
  ///
  /// Parameters:
  /// - `product` (Products): The product with updated information. This is a
  ///   required parameter.
  ///
  /// - `productImage` (File?): An optional parameter representing the updated
  ///   product image. If provided, the product image will be updated; otherwise,
  ///   the existing image will be retained.
  ///
  /// Returns:
  /// A [Future] containing a [bool] indicating whether the product was updated
  /// successfully (true) or not (false).
  ///
  /// Throws:
  /// If an error occurs during the process, the error is re-thrown.
  Future<bool> editProduct({
    required Products product,
    File? productImage,
  }) async {
    try {
      // Initialize empty fields and files for the request.
      Map<String, String> fields = {};
      List<Map<String, dynamic>> files = [];

      print(product.notificationPeriod);

      // Populate the fields with updated product information.
      fields.addAll({
        "product_sku": product.productSku,
        "stock": product.stock,
        "charge_by_weight": json.encode(product.chargeByWeight),
        "product_name": product.productName,
        "category": product.category,
        "cost_price": product.costPrice,
        "weight_quantity": product.weightQuantity,
        "price": product.price,
        "expiry_days_notify": jsonEncode(product.notificationPeriod ?? 0),
        "out_of_stock_notify": json.encode(product.outOfStockNotify),
        "low_stock_limit": product.lowStockLimit,
        "weight_unit": product.weightUnit,
        "expire_notify": jsonEncode(
            product.expireDate != null && product.expireDate!.isNotEmpty),
        "expiring_date": product.expireDate ?? "",
      });

      // Check if the product has variations.
      if (product.productsVariation.isEmpty) {
        // If no variations, set default values for one variation.
        fields.addAll({
          "products_variation[0].variations_category": "none",
          "products_variation[0].variation_value": "none",
          "products_variation[0].weight_quantity": "none",
          "products_variation[0].quantity": "none",
        });
      } else {
        int i = 0;

        // Populate fields with variation information.
        for (var element in product.productsVariation) {
          fields.addAll({
            "products_variation[$i]variations_category":
                element["variations_category"],
            "products_variation[$i]variation_value": element["variation_value"],
            "products_variation[$i]weight_quantity":
                element["weight_quantity"] == null
                    ? "0"
                    : element["weight_quantity"].toString(),
            "products_variation[$i]quantity": element["quantity"] == null
                ? "0"
                : element["quantity"].toString(),
          });
          i++;
        }
      }

      // Check if a new product image is provided.
      if (productImage != null) {
        // If a new image is provided, add it to the files for the request.
        files.add({"name": "image", "file": productImage});
      } else {
        // If no new image provided, retain the existing image.
        fields.addAll({
          "image": product.image,
        });
      }

      print(fields);

      // Send the request to edit the product with the updated fields and files.
      return await userServices.editProduct(fields, product.id, files);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Edits an existing product variation within a product.
  ///
  /// This function allows editing an existing product variation within a product.
  /// It follows a specific logic to ensure accurate updates and validation.
  ///
  /// Parameters:
  /// - `product` (Products): The product containing the variation to be edited.
  ///   This is a required parameter.
  ///
  /// - `variation` (Variation): The updated variation information. This is a
  ///   required parameter.
  ///
  /// - `index` (int): The index of the variation to be edited within the product.
  ///   This is a required parameter.
  ///
  /// Returns:
  /// A [Future] containing a [bool] indicating whether the product variation was
  /// edited successfully (true) or not (false).
  ///
  /// Throws:
  /// If an error occurs during the process, the error is re-thrown.
  Future<bool> editProductVariation({
    required Products product,
    required Variation variation,
    required int index,
  }) async {
    try {
      // Remove the product variation at the specified index.
      final removedProductVariation = product.productsVariation.removeAt(index);

      // Check if the updated variation already exists in other variations.
      for (var i in product.productsVariation) {
        if (i["variation_value"].toString().toUpperCase() ==
            variation.variationValue.toUpperCase()) {
          // If the variation already exists, revert the changes and throw an error.
          product.productsVariation.insert(index, removedProductVariation);
          throw "Variation already exists";
        }
      }

      // Insert the updated variation at the specified index.
      product.productsVariation.insert(index, {
        "weight_quantity": product.chargeByWeight
            ? double.parse(variation.variationQuantity).toString()
            : 0.toString(),
        "quantity": product.chargeByWeight
            ? 0.toString()
            : int.parse(variation.variationQuantity).toInt().toString(),
        "variations_category": variation.variationType,
        "variation_value": variation.variationValue,
      });

      // Calculate the stock based on the updated variations.
      dynamic stock = 0;

      for (var element in product.productsVariation) {
        if (product.chargeByWeight) {
          stock += double.parse(element["weight_quantity"].toString());
        } else {
          stock += int.parse(element["quantity"].toString());
        }
      }

      // Update the product's stock and weight quantity based on the variations.
      if (product.chargeByWeight) {
        product.weightQuantity = stock.toString();
        product.stock = 0.toString();
      } else {
        product.weightQuantity = 0.toString();
        product.stock = stock.toString();
      }

      // Prepare the fields for updating the product.
      Map<String, String> fields = {
        "product_sku": product.productSku,
        "stock": product.stock,
        "charge_by_weight": json.encode(product.chargeByWeight),
        "product_name": product.productName,
        "category": product.category,
        "cost_price": product.costPrice,
        "expiry_days_notify": jsonEncode(product.notificationPeriod ?? 0),
        "weight_quantity": product.weightQuantity,
        "image": product.image,
        "price": product.price,
        "out_of_stock_notify": json.encode(product.outOfStockNotify),
        "low_stock_limit": product.lowStockLimit,
        "weight_unit": product.weightUnit,
        "expire_notify": jsonEncode(
            product.expireDate != null && product.expireDate!.isNotEmpty),
        "expiring_date": product.expireDate ?? "",
      };

      // Add the product variations to the fields for the update.
      if (product.productsVariation.isEmpty) {
        // If there are no variations, set default values for one variation.
        fields.addAll({
          "products_variation[0].variations_category": "none",
          "products_variation[0].variation_value": "none",
          "products_variation[0].weight_quantity": "none",
          "products_variation[0].quantity": "none",
        });
      } else {
        int i = 0;

        for (var element in product.productsVariation) {
          fields.addAll({
            "products_variation[$i]variations_category":
                element["variations_category"],
            "products_variation[$i]variation_value": element["variation_value"],
            "products_variation[$i]weight_quantity":
                element["weight_quantity"].toString(),
            "products_variation[$i]quantity": element["quantity"].toString(),
          });
          i++;
        }
      }

      // Send the request to edit the product with the updated fields.
      return await userServices.editProduct(fields, product.id, []);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Deletes a product variation within a product.
  ///
  /// This function allows deleting a product variation within a product and
  /// adjusts the stock and product fields accordingly.
  ///
  /// Parameters:
  /// - `product` (Products): The product containing the variation to be deleted.
  ///   This is a required parameter.
  ///
  /// Returns:
  /// A [Future] containing a [bool] indicating whether the product variation was
  /// deleted successfully (true) or not (false).
  ///
  /// Throws:
  /// If an error occurs during the process, the error is re-thrown.
  Future<bool> deleteProductVariation({required Products product}) async {
    try {
      // Initialize the fields for updating the product.
      Map<String, String> fields = {};

      // Initialize the stock value for calculating.
      dynamic stock = 0;

      if (product.productsVariation.isEmpty) {
        // If there are no variations, set default values for one variation.
        product.stock = "0";

        fields.addAll({
          "products_variation[0].variations_category": "none",
          "products_variation[0].variation_value": "none",
          "products_variation[0].weight_quantity": "none",
          "products_variation[0].quantity": "none",
        });
      } else {
        // Calculate the stock based on the existing variations.
        for (var element in product.productsVariation) {
          if (product.chargeByWeight) {
            stock += double.parse(element["weight_quantity"].toString());
          } else {
            stock += int.parse(element["quantity"].toString());
          }
        }

        // Update the product's stock and weight quantity based on the variations.
        if (product.chargeByWeight) {
          product.weightQuantity = stock.toString();
          product.stock = "0";
        } else {
          product.weightQuantity = "0";
          product.stock = stock.toString();
        }

        // Add the product variations to the fields for the update.
        int i = 0;
        for (var element in product.productsVariation) {
          fields.addAll({
            "products_variation[$i]variations_category":
                element["variations_category"],
            "products_variation[$i]variation_value": element["variation_value"],
            "products_variation[$i]weight_quantity":
                element["weight_quantity"].toString(),
            "products_variation[$i]quantity": element["quantity"].toString(),
          });
          i++;
        }
      }

      // Add other product-related fields to the update fields.
      fields.addAll({
        "product_sku": product.productSku,
        "stock": product.stock,
        "charge_by_weight": json.encode(product.chargeByWeight),
        "product_name": product.productName,
        "category": product.category,
        "cost_price": product.costPrice,
        "weight_quantity": product.weightQuantity,
        "image": product.image,
        "price": product.price,
        "expiry_days_notify": jsonEncode(product.notificationPeriod ?? 0),
        "out_of_stock_notify": json.encode(product.outOfStockNotify),
        "low_stock_limit": product.lowStockLimit,
        "weight_unit": product.weightUnit,
        "expire_notify": jsonEncode(
            product.expireDate != null && product.expireDate!.isNotEmpty),
        "expiring_date": product.expireDate ?? "",
      });

      // Send the request to edit the product with the updated fields.
      return await userServices.editProduct(fields, product.id, []);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Retrieves a list of all product categories.
  ///
  /// This function retrieves a list of all available product categories from the
  /// user services.
  ///
  /// Returns:
  /// A [Future] containing a [List<dynamic>] representing the product categories.
  ///
  /// Throws:
  /// If an error occurs during the retrieval process, the error is re-thrown.
  Future<List<dynamic>> getAllCategories() async {
    try {
      // Retrieve and return the list of product categories from the user services.
      return await userServices.getAllProductsCategories();
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Adds categories to the user's account.
  ///
  /// This function allows adding product categories to the user's account.
  ///
  /// Parameters:
  /// - `categories` (List<int>): A list of category IDs to add to the user's account.
  ///   This is a required parameter.
  ///
  /// Returns:
  /// A [Future] containing a [bool] indicating whether the categories were added
  /// successfully (true) or not (false).
  ///
  /// Throws:
  /// If an error occurs during the process, the error is re-thrown.
  Future<bool> addCategories(List<int> categories) async {
    try {
      // Send a request to add the specified categories to the user's account.
      return await userServices.addToUsersCategories(categories);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Uploads a new product to the system.
  ///
  /// This function allows uploading a new product to the system, including its
  /// details and variations.
  ///
  /// Parameters:
  /// - `productName` (String): The name of the product. This is a required parameter.
  /// - `price` (String): The price of the product. This is a required parameter.
  /// - `outOfStockNotify` (bool): A flag indicating whether to notify when the product
  ///   is out of stock. This is a required parameter.
  /// - `lowStockLimit` (String): The low stock limit for the product. This is a required parameter.
  /// - `weightUnit` (String): The unit of weight for the product. This is a required parameter.
  /// - `stock` (String): The stock quantity of the product. This is a required parameter.
  /// - `category` (String): The category of the product. This is a required parameter.
  /// - `costPrice` (String): The cost price of the product. This is a required parameter.
  /// - `productSKU` (String): The SKU (Stock Keeping Unit) of the product. This is a required parameter.
  /// - `chargeByWeight` (bool): A flag indicating whether the product is charged by weight.
  ///   This is a required parameter.
  /// - `product` (List<Variation>): A list of product variations. This is a required parameter.
  /// - `productImage` (File): An optional product image file.
  ///
  /// Returns:
  /// A [Future] representing the result of the product upload operation.
  ///
  /// Throws:
  /// If an error occurs during the upload process, the error is re-thrown.
  Future uploadProduct({
    required String productName,
    required String price,
    required bool outOfStockNotify,
    required String lowStockLimit,
    required String weightUnit,
    required String stock,
    required String category,
    required String costPrice,
    required String productSKU,
    required String expireDate,
    required bool notifyOnExpire,
    required String? expireNotificationPeriod,
    required bool chargeByWeight,
    required List<Variation> product,
    File? productImage,
  }) async {
    try {
      // Initialize lists and maps to store product data.
      List<Map> productVariations = [];
      Map<String, String> fields = {};
      List<Map<String, dynamic>> productImageFile = [];

      // Iterate through product variations and create a list of variation maps.
      for (var element in product) {
        productVariations.add({
          "variations_category": element.variationType,
          "variation_value": element.variationValue,
          "quantity": element.variationQuantity,
        });
      }

      // Populate the fields map with product details.
      fields.addAll({
        "product_sku": productSKU,
        "product_name": productName,
        "price": price,
        "expiring_date": notifyOnExpire ? expireDate : "",
        "expire_notify": jsonEncode(notifyOnExpire),
        "cost_price": costPrice,
        "weight_unit": weightUnit,
        "charge_by_weight": json.encode(chargeByWeight),
        "out_of_stock_notify": json.encode(outOfStockNotify),
        "category": category,
        "expiry_days_notify":
            notifyOnExpire ? expireNotificationPeriod ?? "" : ""
      });

      // Initialize a counter for variation mapping.
      int i = 0;

      // Determine the stock and weight quantity fields based on chargeByWeight flag.
      if (chargeByWeight) {
        fields.addAll({
          "stock": json.encode(0),
          "weight_quantity": stock,
          "low_stock_limit": double.parse(lowStockLimit).toString(),
        });
        // Map product variations to fields.
        for (var _ in productVariations) {
          fields.addAll({
            "products_variation[$i]variations_category": productVariations[i]
                ["variations_category"],
            "products_variation[$i]variation_value": productVariations[i]
                ["variation_value"],
            "products_variation[$i]weight_quantity": productVariations[i]
                ["quantity"],
            "products_variation[$i]quantity": "0",
          });
          i++;
        }
      } else {
        fields.addAll({
          "weight_quantity": json.encode(0),
          "stock": stock,
          "low_stock_limit": lowStockLimit.toString(),
        });
        // Map product variations to fields.
        for (var _ in productVariations) {
          fields.addAll({
            "products_variation[$i]variations_category": productVariations[i]
                ["variations_category"],
            "products_variation[$i]variation_value": productVariations[i]
                ["variation_value"],
            "products_variation[$i]quantity": productVariations[i]["quantity"],
            "products_variation[$i]weight_quantity": "0",
          });
          i++;
        }
      }

      // If there are no product variations, add placeholder values.
      if (productVariations.isEmpty) {
        fields.addAll({
          "products_variation[0].variations_category": "none",
          "products_variation[0].variation_value": "none",
          "products_variation[0].quantity": "none",
          "products_variation[0].weight_quantity": "none",
        });
      }

      // Process the product image if provided.
      if (productImage != null) {
        final dir = await path_provider.getTemporaryDirectory();
        final targetPath = dir.absolute.path;

        productImageFile.add({
          "name": "image",
          "file": File(await compressImage(
              productImage, targetPath + "/productImage$productSKU.jpg")),
        });
      }

      // Generate an offline product map for backup.
      final offlineProductMap = {
        "product_sku":
            productSKU.isEmpty ? Util.generateProductSKU() : productSKU,
        "product_name": productName,
        "price": price,
        "cost_price": costPrice,
        "weight_quantity": chargeByWeight ? stock : "0",
        "stock": chargeByWeight ? "0" : stock,
        "weight_unit": weightUnit,
        "expiring_date": notifyOnExpire ? expireDate : "",
        "expire_notify": jsonEncode(notifyOnExpire),
        "charge_by_weight": chargeByWeight,
        "out_of_stock_notify": outOfStockNotify,
        "low_stock_limit": lowStockLimit,
        "expiry_days_notify":
            notifyOnExpire ? expireNotificationPeriod ?? "" : "",
        "category": category,
        "products_variation": productVariations,
      };

      // Upload the product to the system using user services.
      return await userServices.uploadProduct(
        fields,
        productImageFile,
        'OfflineProduct' + Util.generateProductSKU(),
        offlineProductMap,
      );
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Initiates a refund for a specific product within an order.
  ///
  /// This function allows initiating a refund for a specific product within an order.
  ///
  /// Parameters:
  /// - `orderId` (String): The unique identifier of the order for which the refund is requested. This is a required parameter.
  /// - `productSKU` (String): The SKU (Stock Keeping Unit) of the product to be refunded. This is a required parameter.
  /// - `quantity` (String): The quantity of the product to be refunded. This is a required parameter.
  ///
  /// Returns:
  /// A [Future] representing the result of the refund request.
  ///
  /// Throws:
  /// If an error occurs during the refund process, the error is re-thrown.
  Future<String> refundProduct({
    required String orderId,
    required String productSKU,
    required String quantity,
  }) async {
    try {
      // Call the user services to initiate the refund.
      return await userServices.refundProduct(orderId, productSKU, quantity);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Initiates a refund for an entire sale order.
  ///
  /// This function allows initiating a refund for an entire sale order.
  ///
  /// Parameters:
  /// - `orderId` (String): The unique identifier of the order for which the refund is requested. This is a required parameter.
  ///
  /// Returns:
  /// A [Future] representing the result of the refund request.
  ///
  /// Throws:
  /// If an error occurs during the refund process, the error is re-thrown.
  Future<String> refundSale({
    required String orderId,
  }) async {
    try {
      // Call the user services to initiate the refund for the entire sale.
      return await userServices.refundSale(orderId);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }

  /// Retrieves products belonging to a specific category.
  ///
  /// This function retrieves a list of products that belong to a specific category.
  ///
  /// Parameters:
  /// - `categoryId` (int): The unique identifier of the category. This is a required parameter.
  ///
  /// Returns:
  /// A [Future] that resolves to a list of [Products] belonging to the specified category.
  ///
  /// Throws:
  /// If an error occurs during the retrieval process, the error is re-thrown.
  Future<List<Products>> getProductByCategory({
    required int categoryId,
  }) async {
    try {
      // Call the user services to get products by category.
      return await userServices.getUsersProductsByCategory(categoryId);
    } catch (e) {
      // If an error occurs during the process, rethrow the error.
      rethrow;
    }
  }
}
