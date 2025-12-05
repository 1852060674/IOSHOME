using System;
using System.Collections.Generic;
using UnityEngine.Purchasing;
using UnityEngine.Purchasing.Extension;

namespace Samples.Purchasing
{
    public class StoreListener : IDetailedStoreListener
    {
        private IStoreController? _storeController;
        
        public event Action? Initialized;
        
        public event Action<string>? InitializeFailed;

        public event Action<PurchaseEventArgs>? PurchaseSucceeded;

        public event Action<string>? PurchaseFailed;

        public void Initialize(IEnumerable<ProductDefinition> productDefinitions)
        {
            var builder = ConfigurationBuilder.Instance(StandardPurchasingModule.Instance());
            builder.AddProducts(productDefinitions);
            UnityPurchasing.Initialize(this, builder);
        }

        public void InitiatePurchase(string productId)
        {
            if (_storeController == null)
            {
                PurchaseFailed?.Invoke("Store not initialized");
                return;
            }
            
            _storeController.InitiatePurchase(productId);
        }

        public SubscriptionInfo? GetSubscriptionInfo(string productId)
        {
            var product = _storeController?.products.WithID(productId);
            return product?.hasReceipt == true ? new SubscriptionManager(product, null).getSubscriptionInfo() : null;
        }

        void IStoreListener.OnInitialized(IStoreController controller, IExtensionProvider extensions)
        {
            _storeController = controller;
            Initialized?.Invoke();
        }

        void IStoreListener.OnInitializeFailed(InitializationFailureReason error) => InitializeFailed?.Invoke($"{error}");

        void IStoreListener.OnInitializeFailed(InitializationFailureReason error, string message) => InitializeFailed?.Invoke($"{error}: {message}");

        PurchaseProcessingResult IStoreListener.ProcessPurchase(PurchaseEventArgs purchaseEvent)
        {
            PurchaseSucceeded?.Invoke(purchaseEvent);
            return PurchaseProcessingResult.Complete;
        }

        void IStoreListener.OnPurchaseFailed(Product product, PurchaseFailureReason failureReason) => PurchaseFailed?.Invoke($"{failureReason}");

        void IDetailedStoreListener.OnPurchaseFailed(Product product, PurchaseFailureDescription failureDescription) => PurchaseFailed?.Invoke($"{failureDescription.reason}");
    }
}