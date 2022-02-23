abstract class SerdesJsonTypeAdapter<T, S> {
  const SerdesJsonTypeAdapter();

  T fromJson(S json);

  S toJson(T object);
}
