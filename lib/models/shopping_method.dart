enum ShoppingMethod {
  curbside,
  delivery,
  inStore,
}

ShoppingMethod getShoppingMethod(int index) {
  switch (index) {
    case 0:
      return ShoppingMethod.curbside;
    case 1:
      return ShoppingMethod.delivery;
    case 2:
      return ShoppingMethod.inStore;
    default:
      return ShoppingMethod.curbside;
  }
}