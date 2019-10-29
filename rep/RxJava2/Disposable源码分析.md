从最简单的代码开始着手，我们先创建一个Disposable对象：
```
Disposable disposable = Observable.create(new ObservableOnSubscribe<String>() {
    @Override
    public void subscribe(ObservableEmitter<String> emitter) throws Exception {

    }
}).subscribe(new Consumer<String>() {
    @Override
    public void accept(String s) throws Exception {

    }
});
```
subscribe()方法最终会调用Observable的如下方法：
```
public final Disposable subscribe(Consumer<? super T> onNext, Consumer<? super Throwable> onError,
         Action onComplete, Consumer<? super Disposable> onSubscribe) {
     ...
     LambdaObserver<T> ls = new LambdaObserver<T>(onNext, onError, onComplete, onSubscribe);
     subscribe(ls);
     return ls;
 }

```
可以看到disposable就是LambdaObserver类的一个对象，该类源码如下：
```
public final class LambdaObserver<T> extends AtomicReference<Disposable>
        implements Observer<T>, Disposable, LambdaConsumerIntrospection {
     ...
      @Override
      public void onNext(T t) {
          if (!isDisposed()) {//此处有判断
              try {
                  onNext.accept(t);
              } catch (Throwable e) {
                  Exceptions.throwIfFatal(e);
                  get().dispose();
                  onError(e);
              }
          }
      }
         
     @Override
     public void dispose() {
         DisposableHelper.dispose(this);
     }
 }
```
分析DisposableHelper类：
```
public enum DisposableHelper implements Disposable {
    /**
     * The singleton instance representing a terminal, disposed state, don't leak it.
     */
    DISPOSED
    ....
    /**
     * Atomically disposes the Disposable in the field if not already disposed.
     * @param field the target field
     * @return true if the current thread managed to dispose the Disposable
     */
    public static boolean dispose(AtomicReference<Disposable> field) {
        Disposable current = field.get();
        Disposable d = DISPOSED;
        if (current != d) {
            current = field.getAndSet(d);
            if (current != d) {
                if (current != null) {
                    current.dispose();
                }
                return true;
            }
        }
        return false;
}
```
Observable.create()方法返回如下类的对象：
```
public final class ObservableCreate<T> extends Observable<T> {
    final ObservableOnSubscribe<T> source;

    public ObservableCreate(ObservableOnSubscribe<T> source) {
        this.source = source;
    }

    @Override
    protected void subscribeActual(Observer<? super T> observer) {
        CreateEmitter<T> parent = new CreateEmitter<T>(observer);
        observer.onSubscribe(parent);

        try {
            source.subscribe(parent);
        } catch (Throwable ex) {
            Exceptions.throwIfFatal(ex);
            parent.onError(ex);
        }
    }

    static final class CreateEmitter<T>
    extends AtomicReference<Disposable>
    implements ObservableEmitter<T>, Disposable {

        private static final long serialVersionUID = -3434801548987643227L;

        final Observer<? super T> observer;

        CreateEmitter(Observer<? super T> observer) {
            this.observer = observer;
        }

        @Override
        public void onNext(T t) {
            ...
            if (!isDisposed()) {//此处有判断
                observer.onNext(t);
            }
        }
        ...
        @Override
        public void setDisposable(Disposable d) {
            DisposableHelper.set(this, d);
        }
        ...
        @Override
        public void dispose() {
            DisposableHelper.dispose(this);
        }

        @Override
        public boolean isDisposed() {
            return DisposableHelper.isDisposed(get());
        }
        ...
    }
   ...

}

```
RxJava的同一个接口有多个实现类，要确定具体调用了哪个实现类的方法，通过Debug是最快的方式.